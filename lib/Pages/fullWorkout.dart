import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/providers/progress_provider.dart';
import 'package:rkfitness/providers/schedule_provider.dart';
import 'package:rkfitness/supabaseMaster/user_progress_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rkfitness/providers/auth_provider.dart';

class FullWorkoutPage extends StatefulWidget {
  final WorkoutTableModel workout;

  const FullWorkoutPage({super.key, required this.workout});

  @override
  State<FullWorkoutPage> createState() => _FullWorkoutPageState();
}

class _FullWorkoutPageState extends State<FullWorkoutPage> {
  bool _isWorkoutFinished = false;

  int _currentSet = 1;
  bool _isResting = false;
  int _restSeconds = 30;
  Timer? _restTimer;

  // State for the work period
  bool _isWorkTimerRunning = false;
  int _workTimerSeconds = 0;
  final int _workDurationSeconds = 20; // 20 seconds work period
  Timer? _workTimer;
  bool _canCompleteSet = false;

  // Cardio variables
  Timer? _cardioTimer;
  Duration _cardioDuration = Duration.zero;
  bool _isCardioPaused = true;
  Duration _initialCardioDuration = Duration.zero;

  // THE OBJECT YOU CORRECTLY IDENTIFIED: Used directly now.
  final UserProgressService _userProgressService = UserProgressService();

  @override
  void initState() {
    super.initState();
    _initializeWorkout();
  }

  Future<void> _initializeWorkout() async {
    final isCardio = widget.workout.workoutType.toLowerCase() == 'cardio';
    final userEmail = Supabase.instance.client.auth.currentUser?.email;
    Duration calculatedDuration = Duration.zero;

    final authProvider = context.read<AuthProvider>();
    final isAdmin = authProvider.currentUser?.userType == 'admin';

    if (isCardio && userEmail != null && !isAdmin) {
      final scheduleProvider = context.read<ScheduleProvider>();
      final schedule = await scheduleProvider.getCustomWorkoutDetailsForToday(
        userEmail,
        widget.workout.workoutId,
      );

      if (schedule != null && schedule['customDuration'] != null) {
        final customDuration = schedule['customDuration'] as int;
        if (customDuration > 0) {
          calculatedDuration = Duration(seconds: customDuration);
        }
      }

      if (calculatedDuration == Duration.zero) {
        calculatedDuration = _parseDuration(widget.workout.duration ?? "00:00");
      }
    } else if (isCardio) {
      calculatedDuration = _parseDuration(widget.workout.duration ?? "00:00");
    }

    if (mounted) {
      setState(() {
        _initialCardioDuration = calculatedDuration;
        _cardioDuration = calculatedDuration;
      });
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _cardioTimer?.cancel();
    _workTimer?.cancel();
    super.dispose();
  }

  Duration _parseDuration(String s) {
    if (s.isEmpty) return Duration.zero;
    int minutes = 0, seconds = 0;
    List<String> parts = s.split(':');
    if (parts.length == 2) {
      minutes = int.tryParse(parts[0]) ?? 0;
      seconds = int.tryParse(parts[1]) ?? 0;
    }
    return Duration(minutes: minutes, seconds: seconds);
  }

  Future<void> _completeWorkoutSession() async {
    // Note: Logging for the final set is handled in _completeSet

    if (mounted) {
      setState(() {
        _isWorkoutFinished = true;
        _restTimer?.cancel();
        _cardioTimer?.cancel();
        _workTimer?.cancel();
      });
    }
  }

  // FIX APPLIED HERE: Direct Service Call
  Future<void> _logWorkoutProgress() async {
    final userEmail = Supabase.instance.client.auth.currentUser?.email;
    if (userEmail == null) return;

    // Use the local service object directly, bypassing the provider hierarchy
    try {
      await _userProgressService.logWorkoutCompletion(
        userEmail: userEmail,
        workout: widget.workout,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              '${widget.workout.workoutName} set completion logged.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error logging progress: ${e.toString()}'),
          ),
        );
      }
    }
  }

  // LOGIC START: Starts the 20-second work timer
  void _startSet() {
    if (mounted) {
      setState(() {
        _isWorkTimerRunning = true;
        _canCompleteSet = false;
        _workTimerSeconds = _workDurationSeconds;
      });
    }

    _workTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_workTimerSeconds > 1) {
        if (mounted) setState(() => _workTimerSeconds--);
      } else {
        _workTimer?.cancel();
        if (mounted) {
          setState(() {
            _isWorkTimerRunning = false;
            _canCompleteSet = true; // Enable Complete button
          });
        }
      }
    });
  }

  // LOGIC COMPLETE: Logs the set, then starts rest or finishes workout
  void _completeSet() {
    // Log progress (1 count per workout ID)
    _logWorkoutProgress();

    if (_currentSet >= (widget.workout.sets ?? 1)) {
      // Final set complete, navigate to final screen
      _completeWorkoutSession();
    } else {
      // Not the final set, start rest timer
      _startRestTimer();
    }
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    if (mounted) {
      setState(() {
        _isResting = true;
        _currentSet++; // Move to next set number
        _restSeconds = 30; // 30 seconds rest
        _canCompleteSet = false; // Reset complete state
      });
    }
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds > 0) {
        if (mounted) setState(() => _restSeconds--);
      } else {
        _skipRest();
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    if (mounted) {
      setState(() {
        _isResting = false;
        // _startSet(); // Returns to the Start Set state
      });
    }
  }

  void _toggleCardioTimer() {
    if (_initialCardioDuration == Duration.zero) return;

    if (mounted) {
      setState(() {
        _isCardioPaused = !_isCardioPaused;
        if (_isCardioPaused) {
          _cardioTimer?.cancel();
        } else {
          _cardioTimer = Timer.periodic(
            const Duration(seconds: 1),
                (_) => _updateCardioTime(),
          );
        }
      });
    }
  }

  void _updateCardioTime() {
    if (_cardioDuration.inSeconds > 0) {
      if (mounted)
        setState(() => _cardioDuration -= const Duration(seconds: 1));
    } else {
      _cardioTimer?.cancel();
      _completeWorkoutSession();
    }
  }

  void _resetCardioTimer() {
    _cardioTimer?.cancel();
    if (mounted) {
      setState(() {
        _cardioDuration = _initialCardioDuration;
        _isCardioPaused = true;
        _isWorkoutFinished = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.currentUser?.userType == 'admin';
    bool isExercise = widget.workout.workoutType.toLowerCase() == 'exercise';

    if (authProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.workout.workoutName),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.workout.workoutName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMediaSection(widget.workout.gifPath),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDescriptionSection(widget.workout.description),
                  SizedBox(height: 20.h),
                  _buildDetailsSection(widget.workout),
                  SizedBox(height: 20.h),

                  if (isAdmin)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Admin View: Progress tracking is disabled.',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      ),
                    )
                  else if (isExercise)
                    _isWorkoutFinished
                        ? _buildFinishedState()
                        : _isResting
                        ? _buildRestingState()
                        : _buildExerciseActiveState()
                  else // Cardio
                    _isWorkoutFinished
                        ? _buildFinishedState()
                        : _buildCardioActiveState(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection(String? gifPath) {
    final workoutGifUrl = gifPath != null
        ? Supabase.instance.client.storage
        .from('image_and_gifs')
        .getPublicUrl(gifPath)
        : 'https://via.placeholder.com/400';

    return Container(
      height: 240.h,
      width: double.infinity,
      color: Theme.of(context).inputDecorationTheme.fillColor,
      child: Image.network(
        workoutGifUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          return progress == null
              ? child
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildDescriptionSection(String? description) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          description ?? 'No description available.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildDetailsSection(WorkoutTableModel workout) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Category:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              workout.workoutCategory ?? 'N/A',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Type:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              workout.workoutType,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciseActiveState() {
    final theme = Theme.of(context);
    final totalSets = widget.workout.sets ?? 1;

    Widget content;

    if (_isWorkTimerRunning) {
      // State 2: Work Timer Running (Button Disabled)
      content = Column(
        children: [
          Text(
            'WORK TIME REMAINING',
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey),
          ),
          Text(
            '$_workTimerSeconds s',
            style: theme.textTheme.displayLarge?.copyWith(color: theme.colorScheme.primary),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null, // Button disabled during work
              child: Text('Set Active - Wait ${_workTimerSeconds}s'),
            ),
          ),
        ],
      );
    } else if (_canCompleteSet) {
      // State 3: Work Timer Finished (Complete Button Enabled)
      content = Column(
        children: [
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeSet, // Log and rest/finish
              child: Text(_currentSet >= totalSets ? 'Finish Workout' : 'Set Complete & Rest'),
            ),
          ),
        ],
      );
    } else {
      // State 1: Initial Start Button (or after rest)
      content = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _startSet,
          child: const Text('Start Set'),
        ),
      );
    }


    return Column(
      children: [
        Text(
          'Set $_currentSet of $totalSets',
          style: theme.textTheme.headlineSmall,
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatBox('Sets', widget.workout.sets.toString()),
            _buildStatBox('Reps', widget.workout.reps.toString()),
          ],
        ),
        SizedBox(height: 20.h),
        content,
      ],
    );
  }

  Widget _buildRestingState() {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Rest',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        Text('$_restSeconds', style: theme.textTheme.displayLarge),
        SizedBox(height: 20.h),
        TextButton(
          onPressed: _skipRest,
          child: Text(
            'Skip Rest',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinishedState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 80.w),
          SizedBox(height: 16.h),
          Text('Workout Complete!', style: theme.textTheme.headlineMedium),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Schedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String? value) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value ?? 'N/A',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardioActiveState() {
    final theme = Theme.of(context);
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(_cardioDuration.inMinutes.remainder(60));
    final seconds = strDigits(_cardioDuration.inSeconds.remainder(60));

    final isDisabled = _initialCardioDuration == Duration.zero;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$minutes:$seconds',
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isDisabled)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'Loading duration...',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay),
              iconSize: 32.w,
              onPressed: isDisabled ? null : _resetCardioTimer,
              color: isDisabled ? Colors.grey : theme.colorScheme.onSurface,
            ),
            SizedBox(width: 20.w),
            IconButton(
              icon: Icon(_isCardioPaused ? Icons.play_arrow : Icons.pause),
              iconSize: 64.w,
              style: IconButton.styleFrom(
                backgroundColor: isDisabled
                    ? Colors.grey
                    : theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: isDisabled ? null : _toggleCardioTimer,
            ),
            SizedBox(width: 52.w),
          ],
        ),
      ],
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ADDED
import 'package:provider/provider.dart';
import 'package:rkfitness/main.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/providers/progress_provider.dart';
import 'package:rkfitness/providers/schedule_provider.dart';
import 'package:rkfitness/supabaseMaster/user_progress_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FullWorkoutPage extends StatefulWidget {
  final WorkoutTableModel workout;

  const FullWorkoutPage({super.key, required this.workout});

  @override
  State<FullWorkoutPage> createState() => _FullWorkoutPageState();
}

class _FullWorkoutPageState extends State<FullWorkoutPage> {
  // NOTE: This MyApp reference is unnecessary and can be safely ignored but kept for compatibility.
  // MyApp myApp = MyApp();
  bool _isWorkoutFinished = false;

  int _currentSet = 1;
  bool _isSetInProgress = false;
  bool _canCompleteSet = false;
  bool _isResting = false;
  int _restSeconds = 30;
  Timer? _restTimer;

  Timer? _cardioTimer;
  Duration _cardioDuration = Duration.zero;
  bool _isCardioPaused = true;
  Duration _initialCardioDuration = Duration.zero;
  UserProgressService _userProgressService = UserProgressService();

  @override
  void initState() {
    super.initState();
    _initializeWorkout();
  }

  Future<void> _initializeWorkout() async {
    final isCardio = widget.workout.workoutType.toLowerCase() == 'cardio';
    final userEmail = Supabase.instance.client.auth.currentUser?.email;
    Duration calculatedDuration = Duration.zero;

    if (isCardio && userEmail != null) {
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

  // Final completion step: logs progress and sets finished flag
  Future<void> _completeWorkoutSession() async {
    await _logWorkoutProgress();

    if (mounted) {
      setState(() {
        _isWorkoutFinished = true;
        // Ensure timers are cancelled on completion
        _restTimer?.cancel();
        _cardioTimer?.cancel();
      });
    }
  }
  
  // Renamed to internal logging logic
  Future<void> _logWorkoutProgress() async {
    final userEmail = Supabase.instance.client.auth.currentUser?.email;
    if (userEmail == null) return;

    final progressProvider = context.read<ProgressProvider>();
    
    try {
      await progressProvider.logWorkoutCompletion(
        userEmail: userEmail,
        workout: widget.workout,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              '${widget.workout.workoutName} completed and progress logged!',
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

  // UPDATED: Start button logic simplified. Now just enables the Complete button.
  void _startSet() {
    setState(() {
      _isSetInProgress = true;
      _canCompleteSet = true;
    });
  }

  // UPDATED: Complete button now calls _completeWorkoutSession, ending the cycle.
  void _completeSet() {
    // Check if this is the final set before logging the whole workout
    if (_currentSet >= (widget.workout.sets ?? 1)) {
       _completeWorkoutSession(); // Log final completion
    } else {
      // Not the final set, log current set and start rest timer
      _logWorkoutProgress(); 
      _startRestTimer();
    }
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    if (mounted) {
      setState(() {
        _isResting = true;
        _isSetInProgress = false;
        _restSeconds = 30;
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
        _currentSet++;
      });
    }
  }

  // DEFINITION FOR TOGGLE CARDIO TIMER (Required for the crash fix)
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

  // UPDATED: Cardio timer update now calls _completeWorkoutSession on finish.
  void _updateCardioTime() {
    if (_cardioDuration.inSeconds > 0) {
      if (mounted)
        setState(() => _cardioDuration -= const Duration(seconds: 1));
    } else {
      _cardioTimer?.cancel();
      _completeWorkoutSession(); // Log final completion
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
    bool isExercise = widget.workout.workoutType.toLowerCase() == 'exercise';
    return Scaffold(
      appBar: AppBar(
        // FIX: Explicitly set leading to ensure correct navigation behavior
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
                  if (isExercise)
                    _isWorkoutFinished
                        ? _buildFinishedState()
                        : _isResting
                        ? _buildRestingState()
                        : _buildExerciseActiveState()
                  else
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
      // Use responsive height (35% of design height)
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            // Logic is now consolidated into _completeWorkoutSession
            onPressed: _completeWorkoutSession,
            child: const Text('Complete Workout'),
          ),
        ),
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

            //logWorkoutCompletion
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
              onPressed: isDisabled ? null : _toggleCardioTimer, // This should now correctly refer to the State method.
            ),
            SizedBox(width: 52.w),
          ],
        ),
      ],
    );
  }
}
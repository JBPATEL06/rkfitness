import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rkfitness/main.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/providers/progress_provider.dart';
import 'package:rkfitness/providers/schedule_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FullWorkoutPage extends StatefulWidget {
  final WorkoutTableModel workout;

  const FullWorkoutPage({super.key, required this.workout});

  @override
  State<FullWorkoutPage> createState() => _FullWorkoutPageState();
}

class _FullWorkoutPageState extends State<FullWorkoutPage> {
  MyApp myApp = MyApp();
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

  void _startSet() {
    setState(() {
      _isSetInProgress = true;
      _canCompleteSet = false;
    });
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted) {
        setState(() => _canCompleteSet = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can now complete the set!')),
        );
      }
    });
  }

  void _completeSet() {
    _logWorkoutProgress();

    if (_currentSet < (widget.workout.sets ?? 1)) {
      _startRestTimer();
    } else {
      _finishWorkoutSession();
    }
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _isResting = true;
      _isSetInProgress = false;
      _restSeconds = 30;
    });
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

  void _finishWorkoutSession() {
    if (mounted) {
      setState(() {
        _isWorkoutFinished = true;
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
      _logWorkoutProgress();
      _finishWorkoutSession();
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
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () async {
        //     final page = await _backscreen();
        //     if (!mounted) return;
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => page),
        //     );
        //   },
        // ),
        title: Text(widget.workout.workoutName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMediaSection(widget.workout.gifPath),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDescriptionSection(widget.workout.description),
                  const SizedBox(height: 20),
                  _buildDetailsSection(widget.workout),
                  const SizedBox(height: 20),
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
      height: MediaQuery.of(context).size.height * 0.35,
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
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
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
        const SizedBox(height: 4),
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
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatBox('Sets', widget.workout.sets.toString()),
            _buildStatBox('Reps', widget.workout.reps.toString()),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: !_isSetInProgress
                ? _startSet
                : (_canCompleteSet ? _completeSet : null),
            child: Text(_isSetInProgress ? 'Complete' : 'Start'),
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
        const SizedBox(height: 20),
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
          Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          Text('Workout Complete!', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 20),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'N/A',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Loading duration...',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay),
              iconSize: 32,
              onPressed: isDisabled ? null : _resetCardioTimer,
              color: isDisabled ? Colors.grey : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: Icon(_isCardioPaused ? Icons.play_arrow : Icons.pause),
              iconSize: 64,
              style: IconButton.styleFrom(
                backgroundColor: isDisabled
                    ? Colors.grey
                    : theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: isDisabled ? null : _toggleCardioTimer,
            ),
            const SizedBox(width: 52),
          ],
        ),
      ],
    );
  }
}
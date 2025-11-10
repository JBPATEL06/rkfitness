import 'package:flutter/material.dart';
import 'package:rkfitness/models/scheduled_workout_model.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/supabaseMaster/schedual_services.dart';
import 'package:rkfitness/supabaseMaster/workout_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddToSchedulePage extends StatefulWidget {
  final String userEmail;
  final String selectedDay;

  const AddToSchedulePage({
    super.key,
    required this.userEmail,
    required this.selectedDay,
  });

  @override
  State<AddToSchedulePage> createState() => _AddToSchedulePageState();
}

class _AddToSchedulePageState extends State<AddToSchedulePage> {
  final WorkoutTableService _workoutService = WorkoutTableService();
  final ScheduleWorkoutService _scheduleService = ScheduleWorkoutService();
  String _selectedWorkoutType = 'Exercise';
  String? _selectedCategory;
  List<WorkoutTableModel> _allWorkouts = [];
  List<WorkoutTableModel> _filteredWorkouts = [];
  List<String> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  Future<void> _fetchWorkouts() async {
    final results = await Future.wait([
      _workoutService.getAllWorkouts(),
      _scheduleService.getScheduledWorkoutsForUser(widget.userEmail),
    ]);

    final allWorkoutsData = results[0] as List<WorkoutTableModel>;
    final scheduledWorkouts = results[1] as List<ScheduleWorkoutModel>;

    final scheduledForDayIds = scheduledWorkouts
        .where((s) => s.dayOfWeek == widget.selectedDay)
        .map((s) => s.workoutId)
        .toSet();

    final availableWorkouts = allWorkoutsData
        .where((w) => !scheduledForDayIds.contains(w.workoutId))
        .toList();

    final categories = availableWorkouts
        .where((w) => w.workoutCategory != null)
        .map((w) => w.workoutCategory!)
        .toSet()
        .toList();

    if (mounted) {
      setState(() {
        _allWorkouts = availableWorkouts;
        _categories = categories;
        _filterWorkouts();
        _isLoading = false;
      });
    }
  }

  void _filterWorkouts() {
    setState(() {
      _filteredWorkouts = _allWorkouts.where((workout) {
        final typeMatch =
            workout.workoutType.toLowerCase() == _selectedWorkoutType.toLowerCase();
        final categoryMatch =
            _selectedCategory == null || workout.workoutCategory == _selectedCategory;
        return typeMatch && categoryMatch;
      }).toList();
    });
  }

  Future<void> _addWorkoutToSchedule(WorkoutTableModel workout) async {
    final newScheduleEntry = ScheduleWorkoutModel(
      id: const Uuid().v4(),
      userId: widget.userEmail,
      workoutId: workout.workoutId,
      dayOfWeek: widget.selectedDay,
      orderInDay: 99,
      customSets: workout.sets,
      customReps: workout.reps,
      customDuration: int.tryParse(workout.duration?.split(':').last ?? '') ?? null,
    );

    await _scheduleService.createScheduleWorkout(newScheduleEntry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${workout.workoutName} added to ${widget.selectedDay}'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchWorkouts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add to ${widget.selectedDay}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.colorScheme.primary,
                    ),
                    child: Row(
                      children: [
                        _buildTabItem('Exercise'),
                        _buildTabItem('Cardio'),
                      ],
                    ),
                  ),
                ),
                if (_selectedWorkoutType == 'Exercise') ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Filter',
                        style: theme.textTheme.titleMedium),
                  ),
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: [
                        FilterChip(
                          label: const Text('All Body'),
                          selected: _selectedCategory == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = null;
                              _filterWorkouts();
                            });
                          },
                          selectedColor: theme.colorScheme.primary,
                          checkmarkColor: theme.colorScheme.onPrimary,
                          labelStyle: TextStyle(
                              color: _selectedCategory == null
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface),
                        ),
                        ..._categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = selected ? category : null;
                                  _filterWorkouts();
                                });
                              },
                              selectedColor: theme.colorScheme.primary,
                              checkmarkColor: theme.colorScheme.onPrimary,
                              labelStyle: TextStyle(
                                  color: _selectedCategory == category
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
                Expanded(
                  child: _filteredWorkouts.isEmpty
                      ? const Center(child: Text('No workouts to add.'))
                      : ListView.builder(
                          itemCount: _filteredWorkouts.length,
                          itemBuilder: (context, index) {
                            final workout = _filteredWorkouts[index];
                            return _buildWorkoutListItem(workout);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabItem(String title) {
    final theme = Theme.of(context);
    final isSelected = _selectedWorkoutType == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedWorkoutType = title;
            _selectedCategory = null;
            _filterWorkouts();
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutListItem(WorkoutTableModel workout) {
    final theme = Theme.of(context);
    final gifUrl = workout.gifPath != null
        ? Supabase.instance.client.storage
            .from('image_and_gifs')
            .getPublicUrl(workout.gifPath!)
        : '';

    String subtitleText;
    if (workout.workoutType.toLowerCase() == 'exercise') {
      final sets = workout.sets ?? 'N/A';
      final reps = workout.reps ?? 'N/A';
      subtitleText = 'Sets: $sets, Reps: $reps';
    } else {
      subtitleText = 'Duration: ${workout.duration ?? 'N/A'}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(gifUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.workoutName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleText,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.primary, size: 30),
            onPressed: () => _addWorkoutToSchedule(workout),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rkfitness/Pages/add_to_schedule_page.dart';
import 'package:rkfitness/models/scheduled_workout_model.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/supabaseMaster/schedual_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SchedualPage extends StatefulWidget {
  final String userEmail;
  const SchedualPage({super.key, required this.userEmail});

  @override
  State<SchedualPage> createState() => _SchedualPageState();
}

class _SchedualPageState extends State<SchedualPage> {
  final ScheduleWorkoutService _scheduleService = ScheduleWorkoutService();
  final List<String> daysOfWeek = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  String _selectedDay = 'MON';

  @override
  void initState() {
    super.initState();
    final currentDayIndex = DateTime.now().weekday - 1;
    if (currentDayIndex >= 0 && currentDayIndex < daysOfWeek.length) {
      _selectedDay = daysOfWeek[currentDayIndex];
    }
  }

  void _onDeleteExercise(String scheduleId) async {
    await _scheduleService.deleteScheduleWorkout(scheduleId);
    Fluttertoast.showToast(msg: "Exercise removed from schedule");
    setState(() {});
  }

  void _navigateToAddWorkoutPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddToSchedulePage(
          userEmail: widget.userEmail,
          selectedDay: _selectedDay,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _showEditDialog(ScheduleWorkoutModel schedule, WorkoutTableModel workout) {
    final theme = Theme.of(context);
    final setsController = TextEditingController(text: schedule.customSets?.toString() ?? '');
    final repsController = TextEditingController(text: schedule.customReps?.toString() ?? '');
    final durationController = TextEditingController(text: schedule.customDuration?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${workout.workoutName}', style: theme.textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (workout.workoutType.toLowerCase() == 'exercise') ...[
                TextField(
                  controller: setsController,
                  decoration: const InputDecoration(labelText: 'Sets'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: repsController,
                  decoration: const InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                ),
              ] else ...[
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Duration (seconds)'),
                  keyboardType: TextInputType.number,
                ),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface)),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedSchedule = ScheduleWorkoutModel(
                  id: schedule.id,
                  userId: schedule.userId,
                  workoutId: schedule.workoutId,
                  dayOfWeek: schedule.dayOfWeek,
                  orderInDay: schedule.orderInDay,
                  customSets: int.tryParse(setsController.text),
                  customReps: int.tryParse(repsController.text),
                  customDuration: int.tryParse(durationController.text),
                );

                await _scheduleService.updateScheduleWorkout(updatedSchedule);

                if (mounted) Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Workout Schedule'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: SegmentedButton<String>(
              segments: daysOfWeek.map((day) {
                return ButtonSegment<String>(value: day, label: Text(day));
              }).toList(),
              showSelectedIcon: false,
              selected: {_selectedDay},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedDay = newSelection.first;
                });
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                  return states.contains(MaterialState.selected) ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
                }),
                backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                  return states.contains(MaterialState.selected) ? theme.colorScheme.primary : theme.inputDecorationTheme.fillColor!;
                }),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchScheduledWorkoutsForDay(_selectedDay),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No workouts scheduled.'));
                }
                final scheduledWorkouts = snapshot.data!;
                return ListView.separated(
                  itemCount: scheduledWorkouts.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final workoutData = scheduledWorkouts[index]['Workout Table'] as Map<String, dynamic>;
                    final workout = WorkoutTableModel.fromJson(workoutData);
                    final schedule = ScheduleWorkoutModel.fromJson(scheduledWorkouts[index]);
                    return _buildExerciseListItem(workout: workout, schedule: schedule);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddWorkoutPage,
        child: const Icon(Icons.add                                                                                                                                                                                                                                                                               
        ),

      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchScheduledWorkoutsForDay(String day) async {
    return await _scheduleService.getScheduledWorkoutsForUserWithDetails(widget.userEmail, day);
  }

  Widget _buildExerciseListItem({
    required WorkoutTableModel workout,
    required ScheduleWorkoutModel schedule,
  }) {
    final theme = Theme.of(context);
    final gifUrl = Supabase.instance.client.storage
        .from('image_and_gifs')
        .getPublicUrl(workout.gifPath ?? '');

    String subtitleText;
    if (workout.workoutType.toLowerCase() == 'exercise') {
      final sets = schedule.customSets ?? workout.sets ?? 'N/A';
      final reps = schedule.customReps ?? workout.reps ?? 'N/A';
      subtitleText = 'Sets: $sets, Reps: $reps';
    } else {
      final durationInSeconds = schedule.customDuration;
      if (durationInSeconds != null && durationInSeconds > 0) {
        final minutes = durationInSeconds ~/ 60;
        final seconds = durationInSeconds % 60;
        subtitleText = 'Duration: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      } else {
        subtitleText = 'Duration: ${workout.duration ?? 'N/A'}';
      }
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
              image: DecorationImage(image: NetworkImage(gifUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.workoutName,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(subtitleText, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey),
            onPressed: () => _showEditDialog(schedule, workout),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: theme.colorScheme.primary),
            onPressed: () => _onDeleteExercise(schedule.id),
          ),
        ],
      ),
    );
  }
}
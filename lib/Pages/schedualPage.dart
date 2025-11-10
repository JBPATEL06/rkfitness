import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rkfitness/Pages/fullWorkout.dart';
import 'package:rkfitness/models/scheduled_workout_model.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SchedualPage extends StatefulWidget {
  final String userEmail;

  const SchedualPage({super.key, required this.userEmail});

  @override
  State<SchedualPage> createState() => _SchedualPageState();
}

class _SchedualPageState extends State<SchedualPage> {
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
    try {
      await Supabase.instance.client
          .from('schedual workout')
          .delete()
          .eq('id', scheduleId);

      Fluttertoast.showToast(
        msg: "Exercise removed from schedule",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {});
    } catch (e) {
      print('Error deleting exercise: $e');
      Fluttertoast.showToast(
        msg: "Failed to remove exercise",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _navigateToFullWorkoutPage() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Center(
          child: Text('Workout Schedule', style: TextStyle(color: Colors.white)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: SegmentedButton<String>(
              segments: daysOfWeek.map((day) {
                return ButtonSegment<String>(
                  value: day,
                  label: Text(day),
                );
              }).toList(),
              showSelectedIcon: false,
              selected: {_selectedDay},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedDay = newSelection.first;
                });
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.white;
                  }
                  return Colors.black;
                }),
                backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.red;
                  }
                  return Colors.grey[300]!;
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

                    final gifUrl = Supabase.instance.client.storage
                        .from('image_and_gifs')
                        .getPublicUrl(workout.gifPath ?? '');

                    return _buildExerciseListItem(
                      exerciseName: workout.workoutName,
                      duration: workout.duration ?? 'N/A',
                      gifUrl: gifUrl,
                      scheduleId: schedule.id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToFullWorkoutPage,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchScheduledWorkoutsForDay(String day) async {
    try {
      final response = await Supabase.instance.client
          .from('schedual workout')
          .select('*, "Workout Table"(*)')
          .eq('user_id', widget.userEmail)
          .eq('day_of_week', day);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching scheduled workouts: $e');
      return [];
    }
  }

  Widget _buildExerciseListItem({
    required String exerciseName,
    required String duration,
    required String gifUrl,
    required String scheduleId,
  }) {
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
                  exerciseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: $duration',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _onDeleteExercise(scheduleId),
          ),
        ],
      ),
    );
  }
}
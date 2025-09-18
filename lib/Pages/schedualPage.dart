import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rkfitness/Pages/fullWorkout.dart';


class SchedualPage extends StatefulWidget {
  final String userEmail;

  const SchedualPage({super.key, required this.userEmail});

  @override
  State<SchedualPage> createState() => _SchedualPageState();
}

class _SchedualPageState extends State<SchedualPage> {
  final List<String> _exercises = [
    'Chest',
    'Chest',
    'Chest',
    'Chest',
    'Chest',
  ];

  String _selectedDay = 'TUE';

  void _onDeleteExercise(int index) {
    Fluttertoast.showToast(
      msg: "Exercise removed from schedule",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _navigateToFullWorkoutPage() {
  }

  @override
  Widget build(BuildContext context) {
    // The list of days to be used in the segmented button.
    final List<String> daysOfWeek = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Center(child: const Text('Workout Schedule',style: TextStyle(color: Colors.white),)),
      ),
      body: Column(
        children: [
          // The new SegmentedButton for day selection
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

          // List of exercises
          Expanded(
            child: ListView.separated(
              itemCount: _exercises.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return _buildExerciseListItem(
                  exerciseName: _exercises[index],
                  duration: '20-25 min',
                  index: index,
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

  Widget _buildExerciseListItem({
    required String exerciseName,
    required String duration,
    required int index,
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
              image: const DecorationImage(
                image: AssetImage('assets/images/elliptical_trainer.gif'),
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
            onPressed: () => _onDeleteExercise(index),
          ),
        ],
      ),
    );
  }
}
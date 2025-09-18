import 'package:flutter/material.dart';
import 'package:rkfitness/customeWidAndFun.dart';

import 'adminAddWorkout.dart';

class AdminWorkoutPage extends StatelessWidget {
  const AdminWorkoutPage({super.key});

  // A helper function to get the screen width
  // A helper function to get the screen height

  // The workout widget you provided

  // A helper function to build a grid of workouts
  Widget _buildWorkoutGrid(BuildContext context, String category) {
    CustomeWidAndFun mywidget = CustomeWidAndFun();
    // Placeholder data for demonstration
    final List<Map<String, String>> workouts = category == 'Cardio'
        ? [
      {'name': 'Treadmill Running', 'image': 'https://www.gifss.com/deportes/atletismo/images/atleta-26.gif'},
      {'name': 'Stationary Cycling', 'image': 'https://www.gifss.com/deportes/atletismo/images/atleta-26.gif'},
      {'name': 'Jumping Rope', 'image': 'https://www.gifss.com/deportes/atletismo/images/atleta-26.gif'},
      {'name': 'Running', 'image': 'https://www.gifss.com/deportes/atletismo/images/atleta-26.gif'},
    ]
        : [
      {'name': 'Elliptical Trainer', 'image': 'https://www.gifss.com/deportes/atletismo/images/atleta-26.gif'},
      {'name': 'Weight Lifting', 'image': 'https://www.gifss.com/deportes/atletismo/images/atleta-26.gif'},
      {'name': 'Push-ups', 'image': 'https://www.gifss.com/deportes/atletismo/images/atleta-26.gif'},
      {'name': 'Squats', 'image': 'https://www.gifss.com/deportes/atletismo/images/atleta-26.gif'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workoutData = workouts[index];
        return mywidget.workout(context, workoutData['image']!, workoutData['name']!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WORKOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.red[700],

          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[400],
            tabs: const [
              Tab(text: 'Cardio',),
              Tab(text: 'Exercise'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWorkoutGrid(context, 'Cardio'),
            _buildWorkoutGrid(context, 'Exercise'),
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: (){

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWorkoutPage()),
          );
        },backgroundColor: Colors.white70,
          child: Icon(Icons.add,color: Colors.red,),),
      ),
    );
  }
}
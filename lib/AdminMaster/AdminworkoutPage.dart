// lib/AdminMaster/AdminworkoutPage.dart
import 'package:flutter/material.dart';
import 'package:rkfitness/customeWidAndFun.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'adminAddWorkout.dart'; // Make sure this import is correct

class AdminWorkoutPage extends StatelessWidget {
  const AdminWorkoutPage({super.key});

  Future<List<WorkoutTableModel>> _fetchWorkouts(String category) async {
    try {
      final response = await Supabase.instance.client
          .from('Workout Table')
          .select()
          .eq('Workout type', category);

      return (response as List)
          .map((workout) => WorkoutTableModel.fromJson(workout))
          .toList();
    } catch (e) {
      print('Error fetching workouts: $e');
      return [];
    }
  }

  Widget _buildWorkoutGrid(BuildContext context, String category) {
    CustomeWidAndFun mywidget = CustomeWidAndFun();
    return FutureBuilder<List<WorkoutTableModel>>(
      future: _fetchWorkouts(category.toLowerCase()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No $category workouts found.'));
        }
        final workouts = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: mywidget.phoneHieght(context) * 0.35,
          ),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workoutData = workouts[index];
            // CORRECTED: Pass the entire workoutData object
            return mywidget.workout(context, workoutData);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WORKOUT',
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.red[700],
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[400],
            tabs: const [
              Tab(text: 'Cardio'),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddWorkoutPage()),
            );
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
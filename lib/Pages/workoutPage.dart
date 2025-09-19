// workout_page.dart

import 'package:flutter/material.dart';
import 'package:rkfitness/customeWidAndFun.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rkfitness/models/workout_table_model.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  Widget _buildWorkoutGrid(BuildContext context, String category) {
    CustomeWidAndFun mywidget = CustomeWidAndFun();

    return FutureBuilder<List<WorkoutTableModel>>(
      future: _fetchWorkoutsByCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No workouts found.'));
        }

        final workouts = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.6,
          ),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            final gifUrl = Supabase.instance.client.storage
                .from('image_and_gifs')
                .getPublicUrl(workout.gifPath ?? '');

            return mywidget.workout12(
              context,
              gifUrl,
              workout.workoutName,
            );
          },
        );
      },
    );
  }

  Future<List<WorkoutTableModel>> _fetchWorkoutsByCategory(String category) async {
    try {
      final response = await Supabase.instance.client
          .from('Workout Table')
          .select()
          .eq('Workout type', category);

      if (response.isEmpty) {
        return [];
      }

      return response.map((data) => WorkoutTableModel.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching workouts: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WORKOUT', style: TextStyle(color: Colors.white)),
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
            // Note the corrected lowercase strings here
            _buildWorkoutGrid(context, 'cardio'),
            _buildWorkoutGrid(context, 'exercise'),
          ],
        ),
      ),
    );
  }
}
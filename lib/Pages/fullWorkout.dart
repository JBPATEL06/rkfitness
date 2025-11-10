import 'package:flutter/material.dart';
import 'package:rkfitness/models/workout_table_model.dart'; // Import model
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class FullWorkoutPage extends StatelessWidget {
  // Now accepts a single WorkoutTableModel object
  final WorkoutTableModel workout;

  const FullWorkoutPage({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    // Get the dynamic GIF URL from the workout object
    final workoutGifUrl = workout.gifPath != null
        ? Supabase.instance.client.storage
        .from('image_and_gifs')
        .getPublicUrl(workout.gifPath!)
        : 'https://via.placeholder.com/150'; // Fallback URL

    return Scaffold(
      appBar: AppBar(
        // Use workout data dynamically
        title: Text(workout.workoutName),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Image.network(
              workoutGifUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Use workout data dynamically
                    workout.description ?? 'No description available.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Use workout data dynamically
                  _buildDetailRow('Category', workout.workoutCategory ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Type', workout.workoutType),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(value),
      ],
    );
  }
}
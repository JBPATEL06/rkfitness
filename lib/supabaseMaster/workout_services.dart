// workout_table_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/workout_table_model.dart';

class WorkoutTableService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // READ: Fetch a single workout record by its ID
  Future<WorkoutTableModel?> getWorkout(String workoutId) async {
    try {
      final response = await _supabaseClient
          .from('Workout Table')
          .select()
          .eq('Workout id', workoutId)
          .single();
      if (response != null) {
        return WorkoutTableModel.fromJson(response);
      }
    } catch (e) {
      print('Error getting workout: $e');
    }
    return null;
  }

  // CREATE: Insert a new workout record and upload the GIF
  Future<void> createWorkoutWithGif({
    required WorkoutTableModel workout,
    required File gifFile,
  }) async {
    try {
      final String gifPath = 'WorkoutGifs/${workout.workoutId}.gif';

      // Upload the GIF file to the bucket
      await _supabaseClient.storage
          .from('image_and_gifs')
          .upload(gifPath, gifFile);

      // Create a map from the workout model's JSON
      final Map<String, dynamic> workoutData = workout.toJson();

      // Manually add the GIF path to the JSON data
      workoutData['Gif Path'] = gifPath;

      // Insert the workout data into the database
      await _supabaseClient.from('Workout Table').insert(workoutData);
    } catch (e) {
      print('Error creating workout with GIF: $e');
    }
  }

  // DELETE: Delete a workout record and its associated GIF
  Future<void> deleteWorkout(String workoutId) async {
    try {
      // First, get the current workout to find the GIF path
      final workout = await getWorkout(workoutId);
      if (workout != null && workout.gifPath != null) {
        // Delete the GIF file from the bucket
        await _supabaseClient.storage.from('image_and_gifs').remove([workout.gifPath!]);
      }
      // Then, delete the record from the database
      await _supabaseClient.from('Workout Table').delete().eq('Workout id', workoutId);
    } catch (e) {
      print('Error deleting workout: $e');
    }
  }
}
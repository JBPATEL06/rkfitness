import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_table_model.dart';

class WorkoutTableService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

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

  Future<void> createWorkoutWithGif({
    required WorkoutTableModel workout,
    required File gifFile,
  }) async {
    try {
      final String gifPath = 'WorkoutGifs/${workout.workoutId}.gif';
      await _supabaseClient.storage
          .from('image_and_gifs')
          .upload(gifPath, gifFile);
      final Map<String, dynamic> workoutData = workout.toJson();
      workoutData['Gif Path'] = gifPath;
      await _supabaseClient.from('Workout Table').insert(workoutData);
    } catch (e) {
      print('Error creating workout with GIF: $e');
    }
  }

  Future<void> updateWorkout({
    required WorkoutTableModel workout,
    File? newGifFile,
  }) async {
    try {
      final Map<String, dynamic> workoutData = workout.toJson();
      if (newGifFile != null) {
        final String gifPath = 'WorkoutGifs/${workout.workoutId}.gif';
        await _supabaseClient.storage
            .from('image_and_gifs')
            .upload(gifPath, newGifFile,
            fileOptions: const FileOptions(upsert: true));
        workoutData['Gif Path'] = gifPath;
      }
      await _supabaseClient
          .from('Workout Table')
          .update(workoutData)
          .eq('Workout id', workout.workoutId);
    } catch (e) {
      print('Error updating workout: $e');
    }
  }

  Future<int> getWorkoutCountByType(String workoutType) async {
    try {
      final response = await _supabaseClient
          .from('Workout Table')
          .select()
          .eq('Workout type', workoutType.toLowerCase())
          .count();
      return response.count ?? 0;
    } catch (e) {
      print('Error getting workout count: $e');
      return 0;
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      final workout = await getWorkout(workoutId);
      if (workout != null && workout.gifPath != null) {
        await _supabaseClient.storage
            .from('image_and_gifs')
            .remove([workout.gifPath!]);
      }
      await _supabaseClient
          .from('Workout Table')
          .delete()
          .eq('Workout id', workoutId);
    } catch (e) {
      print('Error deleting workout: $e');
    }
  }
}
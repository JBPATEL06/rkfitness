import '../utils/logger.dart';
// lib/supabaseMaster/workout_services.dart
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
      return WorkoutTableModel.fromJson(response);
    } catch (e) {
      Logger.error('Error getting workout', e);
      return null;
    }
  }

  Future<List<WorkoutTableModel>> getAllWorkouts() async {
    try {
      final response = await _supabaseClient.from('Workout Table').select();
      return (response as List)
          .map((data) => WorkoutTableModel.fromJson(data))
          .toList();
    } catch (e) {
      Logger.error('Error getting all workouts', e);
      return [];
    }
  }

  Future<List<WorkoutTableModel>> getWorkoutsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    // --- FINAL FIX: Simplified Cleanup (Remove all hyphens/non-hex chars) ---
    // This aggressively strips all formatting and sends the raw 32-character hex string.
    final sanitizedIds = ids.map((id) {
      final cleanHex = id.replaceAll(RegExp(r'[^0-9a-fA-F]'), '').toLowerCase();

      // If it's a 32-character hex string, we send the raw hex string.
      // We rely on PostgreSQL's ability to parse this, which is the most robust way
      // when hyphenation is causing errors.
      if (cleanHex.length == 32) {
        return cleanHex;
      }
      return id;
    }).toList();
    // --- END FINAL FIX ---

    try {
      Logger.debug('FINAL Sanitized IDs sent to Workout Table (Raw Hex): $sanitizedIds');

      final response = await _supabaseClient
          .from('Workout Table')
          .select()
          .filter('Workout id', 'in', sanitizedIds);

      Logger.debug('Workout fetch successful');

      return (response as List)
          .map((data) => WorkoutTableModel.fromJson(data))
          .toList();
    } catch (e) {
      Logger.error('Error getting workouts by IDs', e);
      Logger.error('Original Failed IDs', ids);
      return [];
    }
  }
Future<void> createWorkoutWithGif({
    required WorkoutTableModel workout,
    required File gifFile,
    required String fileName,
  }) async {
    try {
      final String gifPath = 'WorkoutGifs/$fileName';
      await _supabaseClient.storage
          .from('image_and_gifs')
          .upload(gifPath, gifFile);

      final workoutData = workout.toJson();
      workoutData['Gif Path'] = gifPath;

      await _supabaseClient.from('Workout Table').insert(workoutData);
    } catch (e, st) {
      Logger.error('Error creating workout with GIF', e, st);
      rethrow; // <--- RETHROW ADDED HERE TO PROPAGATE THE ERROR
    }
  }
  Future<void> updateWorkout({
    required WorkoutTableModel workout,
    File? newGifFile,
  }) async {
    try {
      final workoutData = workout.toJson();

      if (newGifFile != null) {
        final fileExtension = newGifFile.path.split('.').last;
        final fileName = '${workout.workoutId}.$fileExtension';
        final String gifPath = 'WorkoutGifs/$fileName';

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
    } catch (e, st) {
      Logger.error('Error updating workout', e, st);
    }
  }

  Future<int> getWorkoutCountByType(String workoutType) async {
    try {
      final response = await _supabaseClient
          .from('Workout Table')
          .select('Workout id')
          .eq('Workout type', workoutType.toLowerCase());

      return (response as List).length;
    } catch (e, st) {
      Logger.error('Error getting workout count', e, st);
      return 0;
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      final workout = await getWorkout(workoutId);
      if (workout?.gifPath != null) {
        await _supabaseClient.storage
            .from('image_and_gifs')
            .remove([workout!.gifPath!]);
      }
      await _supabaseClient
          .from('Workout Table')
          .delete()
          .eq('Workout id', workoutId);
    } catch (e, st) {
      Logger.error('Error deleting workout', e, st);
    }
  }
}

// lib/supabaseMaster/schedual_services.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import 'package:intl/intl.dart';
import '../models/scheduled_workout_model.dart';

class ScheduleWorkoutService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // READ: Fetch a single schedule record by its ID
  Future<ScheduleWorkoutModel?> getScheduleWorkout(String id) async {
    try {
      final response = await _supabaseClient
          .from('schedual workout')
          .select()
          .eq('id', id)
          .single();
      return ScheduleWorkoutModel.fromJson(response);
    } catch (e, st) {
      Logger.error('Error getting schedule workout', e, st);
      return null;
    }
  }

  // NEW FUNCTION: Fetch custom details for a specific workout ID for the current day
  Future<ScheduleWorkoutModel?> getCustomWorkoutDetailsForToday(String userId, String workoutId) async {
    try {
      final dayOfWeek = DateFormat('EEE').format(DateTime.now()).toUpperCase();

      final response = await _supabaseClient
          .from('schedual workout')
          .select()
          .eq('user_id', userId)
          .eq('workout_id', workoutId)
          .eq('day_of_week', dayOfWeek)
          .maybeSingle();

      if (response == null) return null;
      return ScheduleWorkoutModel.fromJson(response);
    } catch (e, st) {
      Logger.error('Error fetching custom workout details', e, st);
      return null;
    }
  }

  // READ: Fetch all scheduled workouts for a specific user
  Future<List<ScheduleWorkoutModel>> getScheduledWorkoutsForUser(String userId) async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('schedual workout')
          .select()
          .eq('user_id', userId);
      return response.map((data) => ScheduleWorkoutModel.fromJson(data)).toList();
    } catch (e, st) {
      Logger.error('Error getting scheduled workouts for user', e, st);
      return [];
    }
  }

  // UPDATED FUNCTION: Now correctly filters by day
  Future<List<Map<String, dynamic>>> getScheduledWorkoutsForUserWithDetails(
      String userId, [String? dayOfWeek]) async {
    try {
      var query = _supabaseClient
          .from('schedual workout')
          .select('*, "Workout Table"(*)')
          .eq('user_id', userId);

      if (dayOfWeek != null) {
        query = query.eq('day_of_week', dayOfWeek);
      }

      final response = await query;
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e, st) {
      Logger.error('Error fetching scheduled workouts with details', e, st);
      return [];
    }
  }

  // CREATE: Insert a new scheduled workout record
  Future<void> createScheduleWorkout(ScheduleWorkoutModel schedule) async {
    try {
      await _supabaseClient.from('schedual workout').insert(schedule.toJson());
    } catch (e, st) {
      Logger.error('Error creating schedule workout', e, st);
    }
  }
  // UPDATE: Update an existing scheduled workout
  Future<void> updateScheduleWorkout(ScheduleWorkoutModel schedule) async {
    try {
      await _supabaseClient
          .from('schedual workout')
          .update(schedule.toJson())
          .eq('id', schedule.id);
    } catch (e, st) {
      Logger.error('Error updating schedule workout', e, st);
    }
  }
  // DELETE: Delete a scheduled workout by its ID
  Future<void> deleteScheduleWorkout(String id) async {
    try {
      await _supabaseClient.from('schedual workout').delete().eq('id', id);
    } catch (e, st) {
      Logger.error('Error deleting schedule workout', e, st);
    }
  }
}

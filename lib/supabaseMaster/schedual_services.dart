import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/scheduled_workout_model.dart';
import '../models/workout_table_model.dart'; // Import WorkoutTableModel

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
      if (response != null) {
        return ScheduleWorkoutModel.fromJson(response);
      }
    } catch (e) {
      print('Error getting schedule workout: $e');
    }
    return null;
  }

  // READ: Fetch all scheduled workouts for a specific user
  Future<List<ScheduleWorkoutModel>> getScheduledWorkoutsForUser(String userId) async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('schedual workout')
          .select()
          .eq('user_id', userId);
      return response.map((data) => ScheduleWorkoutModel.fromJson(data)).toList();
    } catch (e) {
      print('Error getting scheduled workouts for user: $e');
      return [];
    }
  }

  // NEW FUNCTION: Fetch all scheduled workouts for a user with workout details
  Future<List<Map<String, dynamic>>> getScheduledWorkoutsForUserWithDetails(String userId) async {
    try {
      final response = await _supabaseClient
          .from('schedual workout')
          .select('*, "Workout Table"(*)')
          .eq('user_id', userId);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching scheduled workouts with details: $e');
      return [];
    }
  }

  // CREATE: Insert a new scheduled workout record
  Future<void> createScheduleWorkout(ScheduleWorkoutModel schedule) async {
    try {
      await _supabaseClient.from('schedual workout').insert(schedule.toJson());
    } catch (e) {
      print('Error creating schedule workout: $e');
    }
  }
  // UPDATE: Update an existing scheduled workout
  Future<void> updateScheduleWorkout(ScheduleWorkoutModel schedule) async {
    try {
      await _supabaseClient
          .from('schedual workout')
          .update(schedule.toJson())
          .eq('id', schedule.id);
    } catch (e) {
      print('Error updating schedule workout: $e');
    }
  }
  // DELETE: Delete a scheduled workout by its ID
  Future<void> deleteScheduleWorkout(String id) async {
    try {
      await _supabaseClient.from('schedual workout').delete().eq('id', id);
    } catch (e) {
      print('Error deleting schedule workout: $e');
    }
  }
}
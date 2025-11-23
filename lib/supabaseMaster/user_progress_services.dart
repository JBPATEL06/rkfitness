// lib/supabaseMaster/user_progress_services.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/user_progress_model.dart';
import '../models/user_model.dart';
import '../models/workout_table_model.dart';

class UserProgressService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // --- READ METHODS (Unchanged) ---

  Future<List<UserProgressModel>> getUserProgress(String userGmailId) async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('user Progress')
          .select()
          .eq('"User Email"', userGmailId);

      Logger.info('USER PROGRESS FETCHED FOR $userGmailId');
      // Logger.debug('Response: $response'); // Optional debug log

      return response.map((data) => UserProgressModel.fromJson(data)).toList();
    } catch (e) {
      Logger.error('Error getting user progress', e);
      return [];
    }
  }

  Future<UserProgressModel?> getProgressForDay(String userGmailId, DateTime day) async {
    try {
      final startOfDay = DateTime(day.year, day.month, day.day).toIso8601String();
      final endOfNextDay = DateTime(day.year, day.month, day.day + 1).toIso8601String();

      final response = await _supabaseClient
          .from('user Progress')
          .select()
          .eq('"User Email"', userGmailId)
          .gte('time stamp', startOfDay)
          .lt('time stamp', endOfNextDay)
          .maybeSingle();

      if (response == null) return null;
      return UserProgressModel.fromJson(response);
    } catch (e, st) {
      Logger.error('Error getting progress for day', e, st);
      return null;
    }
  }

  Future<List<UserModel>> getActiveUsersForDay(DateTime day) async {
    try {
      final startOfDay = DateTime(day.year, day.month, day.day).toIso8601String();
      final endOfNextDay = DateTime(day.year, day.month, day.day + 1).toIso8601String();

      final List<dynamic> progressResponse = await _supabaseClient
          .from('user Progress')
          .select('"User Email"')
          .gte('time stamp', startOfDay)
          .lt('time stamp', endOfNextDay)
          .or('completedExercise.gt.0,completedCardio.gt.0');

      if (progressResponse.isEmpty) return [];

      final List<String> userEmails = progressResponse
          .map((item) => item['User Email'] as String)
          .toSet()
          .toList();

      if (userEmails.isEmpty) return [];

      final List<dynamic> userResponse = await _supabaseClient
          .from('User')
          .select()
          .filter('gmail', 'in', userEmails);

      return userResponse
          .map((data) => UserModel.fromJson(data))
          .toList();
    } catch (e, st) {
      Logger.error('Error getting active users for day', e, st);
      return [];
    }
  }

  // --- NEW HELPER FOR LOCAL STORAGE ---

  // Generates a unique key for the user + date combo (e.g. "completed_2023-10-25_user@gmail.com")
  String _getLocalDailyKey(String userEmail) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return 'completed_workouts_${userEmail}_$today';
  }

  // Modified to fetch from Local Storage instead of DB
  Future<Set<String>> getCompletedWorkoutIdsForToday(String userEmail) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getLocalDailyKey(userEmail);
      final List<String> completedList = prefs.getStringList(key) ?? [];
      return completedList.toSet();
    } catch (e, st) {
      Logger.error('Error getting local completed IDs', e, st);
      return {};
    }
  }

  // --- UPDATE LOGIC (Local Check + DB Update) ---

  Future<void> logWorkoutCompletion({
    required String userEmail,
    required WorkoutTableModel workout,
  }) async {
    final now = DateTime.now();
    // Format Day for the 'day' column (e.g., "MON")
    final dayName = DateFormat('EEE').format(now).toUpperCase();

    // Time boundaries for DB query to find today's row
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfNextDay = DateTime(now.year, now.month, now.day + 1).toIso8601String();

    final isExercise = workout.workoutType.toLowerCase() == 'exercise';

    try {
      // 1. OFFLINE CHECK: Get local list
      final prefs = await SharedPreferences.getInstance();
      final key = _getLocalDailyKey(userEmail);
      final List<String> completedList = prefs.getStringList(key) ?? [];

      // If this workout ID is already in our local list, STOP.
      if (completedList.contains(workout.workoutId)) {
        Logger.info('Workout ${workout.workoutName} already completed today (Local Check). Skipping DB update.');
        return;
      }

      // 2. DB UPDATE: Update the "user Progress" count
      final existingEntry = await _supabaseClient
          .from('user Progress')
          .select()
          .eq('"User Email"', userEmail)
          .gte('time stamp', startOfDay)
          .lt('time stamp', endOfNextDay)
          .maybeSingle();

      if (existingEntry != null) {
        // --- Update Existing Row ---
        final currentProgress = UserProgressModel.fromJson(existingEntry);

        Map<String, dynamic> updateData = {};

        if (isExercise) {
          updateData['completedExercise'] = (currentProgress.completedExerciseCount ?? 0) + 1;
        } else {
          updateData['completedCardio'] = (currentProgress.completedCardioCount ?? 0) + 1;
        }

        await _supabaseClient
            .from('user Progress')
            .update(updateData)
            .eq('id', currentProgress.id);

      } else {
        // --- Insert New Row ---
        final newId = const Uuid().v4();
        final newProgress = UserProgressModel(
          id: newId,
          userEmail: userEmail,
          day: dayName,
          time: now,
          completedExerciseCount: isExercise ? 1 : 0,
          completedCardioCount: !isExercise ? 1 : 0, // If cardio is first, set it to 1
        );

        await _supabaseClient.from('user Progress').insert(newProgress.toJson());
      }

      // 3. SAVE LOCALLY: Add ID to local list so we don't count it again today
      completedList.add(workout.workoutId);
      await prefs.setStringList(key, completedList);

      Logger.info('Workout ${workout.workoutName} logged successfully.');

    } catch (e, st) {
      Logger.error('Error logging workout completion', e, st);
    }
  }

  Future<void> updateUserProgress(UserProgressModel progress) async {
    try {
      if (progress.id.isNotEmpty) {
        await _supabaseClient
            .from('user Progress')
            .update(progress.toJson())
            .eq('id', progress.id);
      }
    } catch (e, st) {
      Logger.error('Error updating user progress', e, st);
    }
  }

  Future<void> deleteUserProgress(String progressId) async {
    try {
      await _supabaseClient.from('user Progress').delete().eq('id', progressId);
    } catch (e, st) {
      Logger.error('Error deleting user progress', e, st);
    }
  }
}
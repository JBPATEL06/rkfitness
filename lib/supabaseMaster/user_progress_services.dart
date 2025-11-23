import '../utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/user_progress_model.dart';
import '../models/user_model.dart';
import '../models/workout_table_model.dart';

class UserProgressService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<UserProgressModel>> getUserProgress(String userGmailId) async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('user Progress')
          .select()
          .eq('"User Email"', userGmailId);

      Logger.info('USER PROGRESS FETCHED FOR $userGmailId');
      Logger.debug('Response: $response');

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

  Future<Set<String>> getCompletedWorkoutIdsForToday(String userEmail) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final response = await _supabaseClient
          .from('user workout logs')
          .select('workout_id')
          .eq('user_email', userEmail)
          .eq('date', today);

      if (response is List) {
        return response
            .map((item) => item['workout_id'] as String)
            .toSet();
      }
      return {};
    } catch (e, st) {
      Logger.error('Error getting completed workout IDs for today', e, st);
      return {};
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

  // FIX APPLIED: Uses model-based mapping to ensure stable field access before updating.
  Future<void> logWorkoutCompletion({
    required String userEmail,
    required WorkoutTableModel workout,
  }) async {
    final today = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(today);
    final dayOfWeek = DateFormat('EEE').format(today).toUpperCase();
    final isExercise = workout.workoutType.toLowerCase() == 'exercise';

    try {
      // 1. CHECK FOR DUPLICATE LOGS FOR TODAY
      final isAlreadyCompleted = await _supabaseClient
          .from('user workout logs')
          .select('workout_id')
          .eq('user_email', userEmail)
          .eq('workout_id', workout.workoutId)
          .eq('date', formattedDate)
          .maybeSingle();

      if (isAlreadyCompleted != null) {
        Logger.info('Workout ${workout.workoutId} already logged today. Skipping update.');
        return; // Exit early if already counted today
      }

      // 2. Log the individual completion event (detailed log table)
      await _supabaseClient.from('user workout logs').insert({
        'user_email': userEmail,
        'workout_id': workout.workoutId,
        'workout_type': workout.workoutType,
        'date': formattedDate,
      });

      // 3. Update the aggregated 'user Progress' table
      // Fetch all columns (*) and rely on the model for reliable key access.
      final existingProgressMap = await _supabaseClient
          .from('user Progress')
          .select('*')
          .eq('"User Email"', userEmail)
          .eq('day', dayOfWeek)
          .maybeSingle();

      if (existingProgressMap != null) {
        // FIX: Use model to reliably parse the data, regardless of database casing
        final progress = UserProgressModel.fromJson(existingProgressMap);

        final String progressId = progress.id;
        final currentExerciseCount = progress.completedExerciseCount ?? 0;
        final currentCardioCount = progress.completedCardioCount ?? 0;

        Map<String, dynamic> updateData = {};

        // Use the model's key for the update payload (PostgREST handles final quoting)
        if (isExercise) {
          updateData['completedExercise'] = currentExerciseCount + 1;
        } else {
          updateData['completedCardio'] = currentCardioCount + 1;
        }

        // Final update should succeed using the stable progressId
        await _supabaseClient.from('user Progress').update(updateData).eq('id', progressId);

      } else {
        // Insert new progress record
        final newProgress = UserProgressModel(
          id: const Uuid().v4(),
          userEmail: userEmail,
          day: dayOfWeek,
          time: today,
          completedExerciseCount: isExercise ? 1 : 0,
          completedCardioCount: !isExercise ? 1 : 0,
        );

        await _supabaseClient.from('user Progress').insert(newProgress.toJson());
      }
    } catch (e, st) {
      Logger.error('Error logging workout completion', e, st);
    }
  }

  Future<void> updateUserProgress(UserProgressModel progress) async {
    try {
      if (progress.id != null) {
        await _supabaseClient
            .from('user Progress')
            .update(progress.toJson())
            .eq('id', progress.id!);
      }
    } catch (e, st) {
      Logger.error('Error updating user progress', e, st);
    }
  }

  Future<void> deleteUserProgress(int progressId) async {
    try {
      await _supabaseClient.from('user Progress').delete().eq('id', progressId);
    } catch (e, st) {
      Logger.error('Error deleting user progress', e, st);
    }
  }
}
import '../utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
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
          .eq('User Email', userGmailId);

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
          .eq('User Email', userGmailId)
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

      // FIX: Use double quotes around the column name to force the space and prevent conversion to camelCase.
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
          .filter('Gmail', 'in', userEmails);

      return userResponse
          .map((data) => UserModel.fromJson(data))
          .toList();
    } catch (e, st) {
      Logger.error('Error getting active users for day', e, st);
      return [];
    }
  }

  Future<void> logWorkoutCompletion({
    required String userEmail,
    required WorkoutTableModel workout,
  }) async {
    final today = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(today);
    final dayOfWeek = DateFormat('EEE').format(today).toUpperCase();

    final isExercise = workout.workoutType.toLowerCase() == 'exercise';

    try {
      final existingProgress = await _supabaseClient
          .from('user Progress')
          .select()
          .eq('User Email', userEmail)
          .eq('time stamp', formattedDate)
          .maybeSingle();

      if (existingProgress != null) {
        final progress = UserProgressModel.fromJson(existingProgress);

        final currentExerciseCount = progress.completedExerciseCount ?? 0;
        final currentCardioCount = progress.completedCardioCount ?? 0;

        Map<String, dynamic> updateData = {};

        if (isExercise) {
          updateData['completedExercise'] = currentExerciseCount + 1;
        } else {
          updateData['completedCardio'] = currentCardioCount + 1;
        }

        if (progress.id != null) {
          await _supabaseClient.from('user Progress').update(updateData).eq('id', progress.id!);
        }
      } else {
        final newProgress = UserProgressModel(
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

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_progress_model.dart';

class UserProgressService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // READ: Fetch all progress records for a single user
  Future<List<UserProgressModel>> getUserProgress(String userGmailId) async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('user Progress')
          .select()
          .eq('Gmail id', userGmailId);
      return response.map((data) => UserProgressModel.fromJson(data)).toList();
    } catch (e) {
      print('Error getting user progress: $e');
      return [];
    }
  }

  // CREATE: Insert a new progress record
  Future<void> createUserProgress(UserProgressModel progress) async {
    try {
      await _supabaseClient.from('user Progress').insert(progress.toJson());
    } catch (e) {
      print('Error creating user progress: $e');
    }
  }

  // UPDATE: Update an existing progress record
  Future<void> updateUserProgress(UserProgressModel progress) async {
    try {
      await _supabaseClient
          .from('user Progress')
          .update(progress.toJson())
          .eq('Gmail id', progress.gmailId!) // Added ! to assert non-null
          .eq('day', progress.day!); // Added ! to assert non-null
    } catch (e) {
      print('Error updating user progress: $e');
    }
  }

  // DELETE: Delete a progress record
  Future<void> deleteUserProgress(String userGmailId, String day) async {
    try {
      await _supabaseClient
          .from('user Progress')
          .delete()
          .eq('Gmail id', userGmailId)
          .eq('day', day);
    } catch (e) {
      print('Error deleting user progress: $e');
    }
  }
}
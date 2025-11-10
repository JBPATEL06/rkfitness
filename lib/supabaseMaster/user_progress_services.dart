// user_progress_services.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/user_progress_model.dart';
import '../models/user_model.dart';

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

  // NEW FUNCTION: Fetch active users and their details for a specific day
  Future<List<UserModel>> getActiveUsersForDay(DateTime day) async {
    try {
      // Format the date to match how it's stored in Supabase (YYYY-MM-DD)
      final String formattedDate = DateFormat('yyyy-MM-dd').format(day);

      // Query the 'user Progress' table and join with the 'USER' table
      final response = await _supabaseClient
          .from('user Progress')
          .select('USER!inner(*)') // Use !inner to ensure we only get users with progress
          .eq('Date', formattedDate);

      if (response.isEmpty) {
        return [];
      }

      // Extract the user data from the joined response
      return (response as List)
          .map((item) => UserModel.fromJson(item['USER']))
          .toList();

    } catch (e) {
      print('Error getting active users for day: $e');
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
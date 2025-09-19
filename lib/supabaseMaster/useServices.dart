// user_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // READ: Fetch a single user by their email (primary key)
  Future<UserModel?> getUser(String userGmail) async {
    try {
      final response = await _supabaseClient
          .from('USER')
          .select()
          .eq('gmail', userGmail)
          .single();

      if (response != null) {
        return UserModel.fromJson(response);
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }

  // CREATE: Insert a new user record
  Future<void> createUser(UserModel user) async {
    try {
      await _supabaseClient.from('USER').insert(user.toJson());
    } on PostgrestException catch (e) {
      // Supabase-specific error for unique constraint violation
      if (e.code == '23505') {
        print('User with this email already exists.');
      } else {
        print('Error creating user: $e');
      }
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  // UPDATE: Update an existing user's data
  Future<void> updateUser(UserModel user) async {
    try {
      await _supabaseClient
          .from('USER')
          .update(user.toJson())
          .eq('gmail', user.gmail);
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  // DELETE: Delete a user record by their email
  Future<void> deleteUser(String userGmail) async {
    try {
      await _supabaseClient.from('USER').delete().eq('gmail', userGmail);
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}
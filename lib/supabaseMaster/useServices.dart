// lib/supabaseMaster/useServices.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import '../models/user_model.dart';

class UserService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<UserModel?> getUser(String userGmail) async {
    try {
      final response = await _supabaseClient
          .from('User')
      // CORRECTED: Uses "Gmail" to match your SQL table
          .select()
          .eq('Gmail', userGmail)
          .single();

      return UserModel.fromJson(response);
    } catch (e, st) {
      Logger.error('Error getting user', e, st);
      return null;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabaseClient.from('User').select();
      return (response as List)
          .map((user) => UserModel.fromJson(user))
          .toList();
    } catch (e, st) {
      Logger.error('Error getting all users', e, st);
      return [];
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _supabaseClient.from('User').insert(user.toJson());
    } on PostgrestException catch (e, st) {
      if (e.code == '23505') {
        Logger.info('User with this email already exists.');
      } else {
        Logger.error('Error creating user', e, st);
      }
    } catch (e, st) {
      Logger.error('Error creating user', e, st);
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _supabaseClient
          .from('User')
          .update(user.toJson())
      // CORRECTED: Uses "Gmail" to match your SQL table
          .eq('Gmail', user.gmail);
    } catch (e, st) {
      Logger.error('Error updating user', e, st);
    }
  }

  Future<void> deleteUser(String userGmail) async {
    try {
      await _supabaseClient.from('User').delete().eq('Gmail', userGmail);
    } catch (e, st) {
      Logger.error('Error deleting user', e, st);
    }
  }
}
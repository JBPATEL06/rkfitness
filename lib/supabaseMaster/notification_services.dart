// notification_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';

class NotificationService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // READ: Fetch a single notification by its ID
  Future<NotificationModel?> getNotification(int id) async {
    try {
      final response = await _supabaseClient
          .from('notification')
          .select()
          .eq('id', id)
          .single();
      if (response != null) {
        return NotificationModel.fromJson(response);
      }
    } catch (e) {
      print('Error getting notification: $e');
    }
    return null;
  }

  // READ: Fetch all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('notification')
          .select();
      return response.map((data) => NotificationModel.fromJson(data)).toList();
    } catch (e) {
      print('Error getting all notifications: $e');
      return [];
    }
  }

  // CREATE: Insert a new notification
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _supabaseClient.from('notification').insert(notification.toJson());
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // UPDATE: Update an existing notification
  Future<void> updateNotification(NotificationModel notification) async {
    try {
      await _supabaseClient
          .from('notification')
          .update(notification.toJson())
          .eq('id', notification.id);
    } catch (e) {
      print('Error updating notification: $e');
    }
  }

  // DELETE: Delete a notification by its ID
  Future<void> deleteNotification(int id) async {
    try {
      await _supabaseClient.from('notification').delete().eq('id', id);
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}
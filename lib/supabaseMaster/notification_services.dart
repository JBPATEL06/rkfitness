// lib/supabaseMaster/notification_services.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

import '../models/notification_model.dart';

class NotificationService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  // FIX: Use the correct, case-sensitive table name 'notification' (lowercase)
  static const String _tableName = 'notification'; 

  // READ: Fetch a single notification by its ID
  Future<NotificationModel?> getNotification(int id) async {
    try {
      final response = await _supabaseClient
          .from(_tableName) // Using corrected table name
          .select()
          .eq('id', id)
          .single();
      {
        return NotificationModel.fromJson(response);
      }
    } catch (e, st) {
      Logger.error('Error getting notification', e, st);
    }
    return null;
  }

  // READ: Fetch all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from(_tableName) // Using corrected table name
          .select()
          .order('id', ascending: false); // Order by newest first
      return response.map((data) => NotificationModel.fromJson(data)).toList();
    } catch (e, st) {
      Logger.error('Error getting all notifications', e, st);
      return [];
    }
  }

  // CREATE: Insert a new notification
  Future<void> createNotification(NotificationModel notification) async {
    try {
      // Get the JSON map and remove the 'id' field before inserting
      final notificationData = notification.toJson();
      if (notificationData.containsKey('id')) {
        notificationData.remove('id');
      }
      
      await _supabaseClient.from(_tableName).insert(notificationData); // Using corrected table name
    } catch (e, st) {
      Logger.error('Error creating notification', e, st);
    }
  }

  // UPDATE: Update an existing notification
  Future<void> updateNotification(NotificationModel notification) async {
    try {
      if (notification.id == null) {
        throw Exception("Cannot update notification: ID is missing.");
      }
      
      await _supabaseClient
          .from(_tableName) // Using corrected table name
          .update(notification.toJson())
          .eq('id', notification.id!); 
    } catch (e, st) {
      Logger.error('Error updating notification', e, st);
    }
  }

  // DELETE: Delete a notification by its ID
  Future<void> deleteNotification(String id) async {
    try {
      await _supabaseClient.from(_tableName).delete().eq('id', id); // Using corrected table name
    } catch (e, st) {
      Logger.error('Error deleting notification', e, st);
    }
  }
}
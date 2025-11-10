import 'package:flutter/material.dart';
import 'package:rkfitness/models/notification_model.dart';
import 'package:rkfitness/supabaseMaster/notification_services.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final NotificationService _notificationService = NotificationService();

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getAllNotifications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNotification(NotificationModel notification) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _notificationService.createNotification(notification);
      _notifications.add(notification);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _notificationService.deleteNotification(id);
      _notifications.removeWhere((notification) => notification.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
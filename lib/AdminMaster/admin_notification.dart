import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rkfitness/models/notification_model.dart';
import 'package:rkfitness/supabaseMaster/notification_services.dart';
import 'package:uuid/uuid.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  Future<void> _refreshNotifications() async {
    if (mounted) {
      setState(() {
        _notificationsFuture = _notificationService.getAllNotifications();
      });
    }
    // Await the future only if called by RefreshIndicator to complete the animation
    await _notificationsFuture;
  }

  Future<void> _sendNotification({
    String? id,
    required String title,
    required String description,
  }) async {
    final bool isUpdate = id != null;

    if (title.isEmpty || description.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Title and description cannot be empty!')),
        );
      }
      return;
    }

    // Use the model which now correctly handles String UUID
    final notificationToSave = NotificationModel(
      id: isUpdate ? id : const Uuid().v4(), 
      title: title,
      description: description,
    );

    try {
      if (isUpdate) {
        await _notificationService.updateNotification(notificationToSave);
      } else {
        await _notificationService.createNotification(notificationToSave);
      }

      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Notification ${isUpdate ? "updated" : "sent"} successfully!')),
        );
      }
      _refreshNotifications();
    } catch (e) {
      print('Error sending/updating notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${isUpdate ? "update" : "send"} notification.')),
        );
      }
    }
  }

  Future<void> _showAddNotificationDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    return _showNotificationDialog(
      titleController: titleController,
      descriptionController: descriptionController,
      actionButtonText: 'Send',
      onSave: () {
        _sendNotification(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
        );
      },
    );
  }

  Future<void> _showEditNotificationDialog(NotificationModel notification) async {
    final TextEditingController titleController = TextEditingController(text: notification.title);
    final TextEditingController descriptionController = TextEditingController(text: notification.description);
    return _showNotificationDialog(
      titleController: titleController,
      descriptionController: descriptionController,
      actionButtonText: 'Save Changes',
      onSave: () {
        _sendNotification(
          id: notification.id,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
        );
      },
    );
  }

  Future<void> _showNotificationDialog({
    required TextEditingController titleController,
    required TextEditingController descriptionController,
    required String actionButtonText,
    required VoidCallback onSave,
  }) {
    final theme = Theme.of(context);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(actionButtonText == 'Send' ? 'New Notification' : 'Edit Notification', style: theme.textTheme.titleLarge),
          content: SingleChildScrollView( // Added SingleChildScrollView for responsiveness
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 15.h),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: onSave,
              child: Text(actionButtonText),
            ),
          ],
        );
      },
    );
  }

  void _deleteNotification(String notificationId, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the notification: "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _notificationService.deleteNotification(notificationId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification deleted successfully!')),
                  );
                }
                _refreshNotifications(); // Refresh list after deletion
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications'),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Sent Notifications',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: RefreshIndicator( // Added Pull-to-Refresh
              onRefresh: _refreshNotifications,
              child: FutureBuilder<List<NotificationModel>>(
                future: _notificationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading notifications: ${snapshot.error.toString()}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No notifications found.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }
                  final notifications = snapshot.data!;
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return Card(
                        elevation: 4, // Increased elevation for better design
                        margin: EdgeInsets.only(bottom: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title ?? 'No Title',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      item.description ?? 'No Description',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (item.id != null) ...[
                                IconButton(
                                  icon: Icon(Icons.edit, color: theme.colorScheme.primary, size: 24.w),
                                  onPressed: () => _showEditNotificationDialog(item),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: theme.colorScheme.error, size: 24.w),
                                  onPressed: () => _deleteNotification(item.id!, item.title ?? 'this notification'),
                                ),
                              ]
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNotificationDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
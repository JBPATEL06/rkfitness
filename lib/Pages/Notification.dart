import 'package:flutter/material.dart';

// Import your UserDashboard page here so you can navigate back to it.

// Class to represent a single notification item
class NotificationItem {
  final String title;
  final String subtitle;

  NotificationItem({
    required this.title,
    required this.subtitle,
  });
}

// Sample data for the notifications
List<NotificationItem> notifications = [
  NotificationItem(
    title: 'New Cardio',
    subtitle: 'Jumping Jack',
  ),
  NotificationItem(
    title: 'New Exercise',
    subtitle: 'Bench press',
  ),
  NotificationItem(
    title: 'New Exercise',
    subtitle: 'Squats',
  ),
];

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // This will navigate back to the previous screen, which should be the user dashboard.
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false, // Align title to the left
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
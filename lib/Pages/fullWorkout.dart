import 'package:flutter/material.dart';

class FullWorkoutPage extends StatelessWidget {
  final String workoutGifUrl;
  final String workoutName;
  final String description;
  final String category;

  const FullWorkoutPage({
    super.key,
    required this.workoutGifUrl,
    required this.workoutName,
    required this.description,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workoutName),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Image.network(
              workoutGifUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Category', category),
                  const SizedBox(height: 8),
                  _buildDetailRow('Type', 'Strength Training'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(value),
      ],
    );
  }
}
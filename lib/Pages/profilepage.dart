import 'package:flutter/material.dart';
import 'package:rkfitness/Pages/bmiPage.dart';
import 'package:rkfitness/Pages/changePassword.dart';
import 'package:rkfitness/Pages/editProfile.dart';
import 'package:rkfitness/Pages/user_dashboard.dart';

import 'CalenderPage.dart';

// Assuming you have a UserDashboard page to navigate back to
// Make sure this file exists in your project

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // A helper widget for the user stats columns
  // Renamed to follow lowerCamelCase conventions
  static Widget _userStatColumn({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // A helper function to build the action buttons with an arrow
  static Widget _buildActionButton(BuildContext context, String title, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: const BorderSide(color: Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            // Navigate back to the UserDashboard page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>  UserDashBoard(),
              ),
            );
          },
        ),
        title: const Text(
          'PROFILE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top red background section
            Container(
              height: 200,
              color: Colors.red,
              alignment: Alignment.topCenter,
              child: const SizedBox(height: 10),
            ),
            // The main content is stacked on top of the red background
            Transform.translate(
              offset: const Offset(0.0, -100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Profile image and user name
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Bhanderi Jeel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'jbhanderi@rku.ac.in',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    // User stats card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // The `const` keyword has been removed here to fix the error
                            _userStatColumn(label: 'Weight', value: '67'),
                            _userStatColumn(label: 'Height(cm)', value: '172'),
                            _userStatColumn(label: 'Age', value: '20'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Action buttons
                    _buildActionButton(context, 'Update Profile', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UpdateProfilePage()),
                      );
                      // Action for Update Profile
                    }),
                    const SizedBox(height: 10),
                    _buildActionButton(context, 'BMI Calculator', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BmiPage()),
                      );
                      // Action for BMI Calculator
                    }),
                    const SizedBox(height: 10),
                    _buildActionButton(context, 'Calendar', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CalendarPage()),
                      );
                      // Action for Calendar
                    }),
                    const SizedBox(height: 20),
                    // Bottom buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Change Password',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'LogOut',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
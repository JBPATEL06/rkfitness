import 'package:flutter/material.dart';
import 'package:rkfitness/AdminMaster/adminUpdateProfile.dart';
import 'package:rkfitness/Pages/changePassword.dart';
import 'package:rkfitness/Pages/loginpage.dart';

import 'adminCalender.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back to the Admin Dashboard
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'PROFILE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(

        child: Column(
          children: [
            // Top section with user info
            Container(
              color: Colors.red,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'User Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'User email id',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Stats section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 2.0
                ),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white
              ),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'Users', value: '30'),
                  _StatItem(label: 'Cardio', value: '20'),
                  _StatItem(label: 'Exercise', value: '20'),
                ],
              ),
            ),

            // Action buttons
            const SizedBox(height: 20),
            _buildActionButton(
              context,
              'Update Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UpdateProfilePage()),
                );
                // Navigate to UpdateAdminProfilePage
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdateAdminProfilePage()));
              },
            ),
            _buildActionButton(
              context,
              'Calendar',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarPage()),
                );
                // Navigate to CalendarPage
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
              },
            ),
            const SizedBox(height: 40),

            _buildActionButton(
              context,
              'Change Password',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                );
                // Navigate to ChangePasswordPage
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
              },
            ),
            _buildActionButton(
              context,
              'Logout',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  LoginPage()),
                  );

                // Handle logout logic
              },
            ),
          ],
        ),
      ),
    );
  }

  // A helper widget for the stat items
  Widget _StatItem({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // A helper function to build a consistent action button
  static Widget _buildActionButton(
      BuildContext context,
      String label, {
        Color backgroundColor = Colors.red,
        Color textColor = Colors.white,
        VoidCallback? onTap,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                label,
                style: TextStyle(fontSize: 18, color: textColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(Icons.arrow_forward_ios, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
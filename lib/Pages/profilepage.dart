import 'package:flutter/material.dart';
import 'package:rkfitness/Pages/bmiPage.dart';
import 'package:rkfitness/Pages/changePassword.dart';
import 'package:rkfitness/Pages/editProfile.dart';
import 'package:rkfitness/Pages/user_dashboard.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart'; // Import your UserService
import 'package:rkfitness/models/user_model.dart'; // Import your UserModel
import 'package:supabase_flutter/supabase_flutter.dart';

import 'CalenderPage.dart';
import 'loginpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final userEmail = Supabase.instance.client.auth.currentUser?.email;
    if (userEmail != null) {
      final user = await _userService.getUser(userEmail);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _signOut() async {
    await Supabase.instance.client.auth.signOut();
    // Navigate to the login page and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  // A helper widget for the user stats columns
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Fallback values if user data is null
    final user = _user;
    final displayName = user?.gmail.split('@').first ?? 'Guest';
    final userEmail = user?.gmail ?? 'N/A';
    final weight = user?.weight?.toStringAsFixed(0) ?? 'N/A';
    final height = user?.height?.toStringAsFixed(0) ?? 'N/A';
    final age = user?.age?.toString() ?? 'N/A';
    final profilePicUrl = user?.profilePicture ?? 'https://via.placeholder.com/150';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            // Navigate back to the UserDashboard page
            Navigator.of(context).pop();
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
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(profilePicUrl),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: const TextStyle(color: Colors.grey),
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
                            _userStatColumn(label: 'Weight', value: weight),
                            _userStatColumn(label: 'Height(cm)', value: height),
                            _userStatColumn(label: 'Age', value: age),
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
                    }),
                    const SizedBox(height: 10),
                    _buildActionButton(context, 'BMI Calculator', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BmiPage()),
                      );
                    }),
                    const SizedBox(height: 10),
                    _buildActionButton(context, 'Calendar', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CalendarPage()),
                      );
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
                        onPressed: _signOut,
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
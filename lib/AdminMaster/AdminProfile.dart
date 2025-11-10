import 'package:flutter/material.dart';
import 'package:rkfitness/AdminMaster/adminUpdateProfile.dart';
import 'package:rkfitness/Pages/changePassword.dart';
import 'package:rkfitness/Pages/loginpage.dart';
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:rkfitness/supabaseMaster/workout_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'adminCalender.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final UserService _userService = UserService();
  final WorkoutTableService _workoutService = WorkoutTableService();
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchProfileData();
  }

  Future<Map<String, dynamic>> _fetchProfileData() async {
    final adminEmail = Supabase.instance.client.auth.currentUser?.email;
    if (adminEmail == null) {
      throw Exception("User not logged in");
    }

    // Fetch all data in parallel for efficiency
    final results = await Future.wait([
      _userService.getUser(adminEmail),
      _userService.getAllUsers(),
      _workoutService.getWorkoutCountByType('cardio'),
      _workoutService.getWorkoutCountByType('exercise'),
    ]);

    final admin = results[0] as UserModel?;
    final totalUsers = (results[1] as List<UserModel>).length;
    final totalCardio = results[2] as int;
    final totalExercise = results[3] as int;

    return {
      'admin': admin,
      'totalUsers': totalUsers,
      'totalCardio': totalCardio,
      'totalExercise': totalExercise,
    };
  }

  void _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PROFILE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load profile data.'));
          }

          final data = snapshot.data!;
          final UserModel? admin = data['admin'];
          final String totalUsers = data['totalUsers'].toString();
          final String totalCardio = data['totalCardio'].toString();
          final String totalExercise = data['totalExercise'].toString();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Top section with user info
                Container(
                  color: Colors.red,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: admin?.profilePicture != null
                            ? NetworkImage(admin!.profilePicture!)
                            : null,
                        child: admin?.profilePicture == null
                            ? const Icon(Icons.person,
                            size: 80, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        admin?.name ?? 'Admin',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        admin?.gmail ?? 'admin@example.com',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats section
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2.0),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(label: 'Users', value: totalUsers),
                      _StatItem(label: 'Cardio', value: totalCardio),
                      _StatItem(label: 'Exercise', value: totalExercise),
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
                      MaterialPageRoute(
                          builder: (context) => const UpdateProfilePage()),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  'Calendar',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CalendarPage()),
                    );
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
                      MaterialPageRoute(
                          builder: (context) => const ChangePasswordPage()),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  'Logout',
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  onTap: _signOut,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
import 'package:flutter/material.dart';
import 'package:rkfitness/AdminMaster/admin_update_profile.dart';
import 'package:rkfitness/AdminMaster/admin_Dashboard.dart';
import 'package:rkfitness/Pages/changePassword.dart';
import 'package:rkfitness/Pages/loginpage.dart';
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:rkfitness/supabaseMaster/workout_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_calendar.dart';

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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('PROFILE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (context) =>  AdminDashboard())),
        ),
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
                Container(
                  color: theme.colorScheme.primary,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.surface,
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
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        admin?.gmail ?? 'admin@example.com',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.primary, width: 2.0),
                      borderRadius: BorderRadius.circular(16),
                      color: theme.colorScheme.surface),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(context, label: 'Users', value: totalUsers),
                      _StatItem(context, label: 'Cardio', value: totalCardio),
                      _StatItem(context, label: 'Exercise', value: totalExercise),
                    ],
                  ),
                ),

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
                  isPrimary: true,
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
                  isPrimary: true,
                  onTap: _signOut,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _StatItem(BuildContext context, {required String label, required String value}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  static Widget _buildActionButton(
      BuildContext context,
      String label, {
        bool isPrimary = false,
        VoidCallback? onTap,
      }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        onPressed: onTap,
        style: isPrimary
            ? theme.elevatedButtonTheme.style
            : ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey, width: 2),
          ),
          textStyle: theme.textTheme.titleMedium,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Text(
                label,
                style: TextStyle(color: isPrimary ? Colors.white : theme.colorScheme.onSurface),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Icon(Icons.arrow_forward_ios, color: isPrimary ? Colors.white : theme.colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
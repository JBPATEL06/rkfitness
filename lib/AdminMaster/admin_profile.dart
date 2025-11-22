import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rkfitness/AdminMaster/admin_update_profile.dart';
import 'package:rkfitness/AdminMaster/admin_Dashboard.dart';
import 'package:rkfitness/Pages/changePassword.dart';
import 'package:rkfitness/Pages/loginpage.dart';
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:rkfitness/supabaseMaster/workout_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rkfitness/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();

    // 1. Clear local provider state
    if (mounted) {
      context.read<UserProvider>().clearUser();
    }
    
    // 2. Clear Shared Preferences
    await prefs.clear();

    // 3. Clear Supabase session and navigate safely
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
        // FIX: Changed icon from arrow_back to close
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white), // CHANGED ICON
          onPressed: () => Navigator.pop(context),
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
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: theme.colorScheme.surface,
                        backgroundImage: admin?.profilePicture != null
                            ? NetworkImage(admin!.profilePicture!)
                            : null,
                        child: admin?.profilePicture == null
                            ? Icon(Icons.person,
                            size: 80.w,
                            color: Colors.grey)
                            : null,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        admin?.name ?? 'Admin',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5.h),
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
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  margin:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.primary, width: 2.0),
                      borderRadius: BorderRadius.circular(16.r),
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

                SizedBox(height: 20.h),
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
                SizedBox(height: 40.h),

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
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: ElevatedButton(
        onPressed: onTap,
        style: isPrimary
            ? theme.elevatedButtonTheme.style
            : ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: BorderSide(color: Colors.grey, width: 2),
          ),
          textStyle: theme.textTheme.titleMedium,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Text(
                label,
                style: TextStyle(color: isPrimary ? Colors.white : theme.colorScheme.onSurface),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Icon(Icons.arrow_forward_ios, color: isPrimary ? Colors.white : theme.colorScheme.primary, size: 18.w),
            ),
          ],
        ),
      ),
    );
  }
}
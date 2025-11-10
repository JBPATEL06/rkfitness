import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rkfitness/Pages/bmiPage.dart';
import 'package:rkfitness/Pages/changePassword.dart';
import 'package:rkfitness/Pages/editProfile.dart';
import 'package:rkfitness/providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'calendar_page.dart';
import 'loginpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load user data when component mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
    });
  }

  void _signOut() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  static Widget _userStatColumn(BuildContext context, {required String label, required String value}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  static Widget _buildActionButton(BuildContext context, String title, VoidCallback onPressed) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    
    if (userProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (userProvider.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${userProvider.error}'),
              ElevatedButton(
                onPressed: () => userProvider.reloadUser(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final user = userProvider.currentUser;
    final displayName = user?.gmail.split('@').first ?? 'Guest';
    final userEmail = user?.gmail ?? 'N/A';
    final weight = user?.weight?.toStringAsFixed(0) ?? 'N/A';
    final height = user?.height?.toStringAsFixed(0) ?? 'N/A';
    final age = user?.age?.toString() ?? 'N/A';
    final profilePicUrl = user?.profilePicture ?? 'https://via.placeholder.com/150';

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFILE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150,
              color: theme.colorScheme.primary,
              alignment: Alignment.topCenter,
              child: const SizedBox(height: 10),
            ),
            Transform.translate(
              offset: const Offset(0.0, -90),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.surface,
                      backgroundImage: NetworkImage(profilePicUrl),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
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
                            _userStatColumn(context, label: 'Weight (kg)', value: weight),
                            _userStatColumn(context, label: 'Height(cm)', value: height),
                            _userStatColumn(context, label: 'Age', value: age),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionButton(context, 'Update Profile', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UpdateProfilePage()),
                      );
                    }),
                    _buildActionButton(context, 'BMI Calculator', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BmiPage()),
                      );
                    }),
                    _buildActionButton(context, 'Calendar', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CalendarPage()),
                      );
                    }),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                          );
                        },
                        child: const Text(
                          'Change Password',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signOut,
                        child: const Text(
                          'LogOut',
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
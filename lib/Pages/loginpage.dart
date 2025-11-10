import 'package:flutter/material.dart';
import 'package:rkfitness/AdminMaster/admin_Dashboard.dart';
import 'package:rkfitness/Pages/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rkfitness/main.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:rkfitness/supabaseMaster/schedual_services.dart';
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/models/scheduled_workout_model.dart';
import 'package:uuid/uuid.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client;
  final UserService _userService = UserService();
  final ScheduleWorkoutService _scheduleService = ScheduleWorkoutService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final userEmail = _emailController.text.trim();
      final password = _passwordController.text;
      AuthResponse response;

      // Try to get the user from the custom USER table
      final existingUser = await _userService.getUser(userEmail);

      if (existingUser == null) {
        // User does not exist in the USER table, so we'll try to sign them up.
        response = await supabase.auth.signUp(
          email: userEmail,
          password: password,
        );
        // Create the user's record and default schedule after successful sign up
        await _createAndProvisionNewUser(userEmail, response.user?.id);
      } else {
        // User already exists, proceed with standard sign-in.
        response = await supabase.auth.signInWithPassword(
          email: userEmail,
          password: password,
        );
      }

      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Login successful!"),
        ),
      );

      if (response.user != null) {
        // Check userType to navigate to the correct dashboard
        final user = await _userService.getUser(userEmail);
        if (user?.userType == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserDashBoard()),
          );
        }
      } else {
        debugPrint("Error in session set: ${response.user}");
      }
    } on AuthException catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      debugPrint("Login error code: ${e.code}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.message)),
      );
    } catch (e) {
      Navigator.of(context).pop();
      debugPrint("Unexpected Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("An unexpected error occurred."),
        ),
      );
    }
  }

  Future<void> _createAndProvisionNewUser(String userEmail, String? userId) async {
    // Create user record in the USER table
    final newUser = UserModel(
      gmail: userEmail,
      name: userEmail.split('@')[0],
      userType: 'user', // Set default userType
    );
    await _userService.createUser(newUser);

    // Create a default workout schedule
    await _createDefaultSchedule(userEmail);
  }

  Future<void> _createDefaultSchedule(String userEmail) async {
    final Uuid uuid = Uuid();
    final List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    // You should replace these with actual workout IDs from your 'Workout Table'
    const List<String> dummyWorkoutIds = [
      'd8f08bfc-4a7e-46cd-8c0a-26063f4a3e74',
      'b6d218f1-464a-4467-9879-98e907a9c8e8',
    ];

    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final workoutId = dummyWorkoutIds[i % dummyWorkoutIds.length];

      final newSchedule = ScheduleWorkoutModel(
        id: uuid.v4(),
        userId: userEmail,
        workoutId: workoutId,
        dayOfWeek: day,
        orderInDay: 1,
      );
      await _scheduleService.createScheduleWorkout(newSchedule);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/login_background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  const Text(
                    "RKU Fitness",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Card(
                    elevation: 4,
                    color: Colors.white12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email, color: Colors.white),
                          hintText: "example@gmail.com",
                          hintStyle: TextStyle(color: Colors.white54),
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    color: Colors.white12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.lock, color: Colors.white),
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    onPressed: login,
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 30,),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
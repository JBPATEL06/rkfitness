import 'package:flutter/material.dart';
import 'package:rkfitness/AdminMaster/admin_Dashboard.dart';
import 'package:rkfitness/Pages/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rkfitness/main.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      Navigator.of(context).pop(); // Close loading dialog

      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Login successful!"),
        ),
      );

      if (response.user != null) {
        final session = Supabase.instance.client.auth.currentSession;
        debugPrint("🔐 Session: ${response.session?.accessToken}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserDashBoard()),
        );
      } else {
        debugPrint("Error in session set: ${response.user}");
      }
      // Navigate to Home
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

    @override
    void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      super.dispose();
    }
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

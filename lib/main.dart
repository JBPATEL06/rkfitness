import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rkfitness/Pages/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'connection.dart';
import 'Pages/loginpage.dart';

// Toggle this to enable/disable debug helpers
const bool kDebugTools = true;
bool checkloggin = false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp( MyApp());

  // ⚡ Initialize Supabase in background
  Future.microtask(() async {
    await initializeSupabase();
    debugPrint("✅ Supabase initialized");
  });

}class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isLoggedIn() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? login = pref.getBool("login");
    return login ?? false; // Use null-aware operator for safety
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while we wait for the result
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasData) {
            // Based on the data, show the correct page
            return snapshot.data! ?  UserDashBoard() : const LoginPage();
          } else {
            // Handle cases with no data or errors
            return const LoginPage();
          }
        },
      ),
    );
  }
}
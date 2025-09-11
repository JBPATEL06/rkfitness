import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rkfitness/Pages/user_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'connection.dart';
import 'Pages/loginpage.dart';

// Toggle this to enable/disable debug helpers
const bool kDebugTools = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚡ Run app immediately
  runApp(const MyApp());

  // ⚡ Initialize Supabase in background
  Future.microtask(() async {
    await initializeSupabase();
    debugPrint("✅ Supabase initialized");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // // Debug helpers
      // showPerformanceOverlay: kDebugTools && kDebugMode,
      // checkerboardRasterCacheImages: kDebugTools && kDebugMode,
      // checkerboardOffscreenLayers: kDebugTools && kDebugMode,

      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home:  LoginPage(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        // User is logged in, navigate to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) =>  UserDashBoard()),
        );
      } else if (event == AuthChangeEvent.signedOut) {
        // User is logged out, navigate to login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while the auth state is being determined
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


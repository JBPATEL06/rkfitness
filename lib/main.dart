import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rkfitness/AdminMaster/admin_Dashboard.dart';
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
  try{
    await Supabase.initialize(
      url: 'https://kduqtcxujuqgsufudjfe.supabase.co', // ✅ Fixed URL
      anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkdXF0Y3h1anVxZ3N1ZnVkamZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcxMzM2OTksImV4cCI6MjA3MjcwOTY5OX0.qTUG2uO7BRThGmDrLC1ZTqA3brF3VWriTGqabGX7m9E'
    );

  }catch(e){
      debugPrint("Error in Connection ✅");
  }
  runApp( MyApp());

  // ⚡ Initialize Supabase in background
  // Future.microtask(() async {
  //   await initializeSupabase();
  //   debugPrint("✅ Supabase initialized");
  // });

}class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    debugPrint("Session is ${session}");
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
    //     useMaterial3: true,
    //   ),
    return MaterialApp(home: session != null ? AdminDashboard() : LoginPage(),
    );
  }
}
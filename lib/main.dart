import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rkfitness/Pages/splash_screen.dart';
import 'package:rkfitness/AdminMaster/admin_Dashboard.dart';
import 'package:rkfitness/Pages/loginpage.dart';
import 'package:rkfitness/Pages/user_dashboard.dart';
import 'package:rkfitness/providers/notification_provider.dart';
import 'package:rkfitness/providers/progress_provider.dart';
import 'package:rkfitness/providers/schedule_provider.dart';
import 'package:rkfitness/providers/user_provider.dart';
import 'package:rkfitness/providers/workout_provider.dart';
import 'package:rkfitness/providers/auth_provider.dart';
import 'package:rkfitness/supabaseMaster/auth_service.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rkfitness/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to portrait only to prevent unnecessary rebuilds
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  const supabaseUrl = 'https://kduqtcxujuqgsufudjfe.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkdXF0Y3h1anVxZ3N1ZnVkamZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcxMzM2OTksImV4cCI6MjA3MjcwOTY5OX0.qTUG2uO7BRThGmDrLC1ZTqA3brF3VWriTGqabGX7m9E';

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Failed to initialize Supabase client');
    rethrow; // Rethrow to prevent app from running without database connection
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RKU Fitness',
        theme: appTheme(context),
        home: const SplashScreen(),
      ),
    );
  }

  Future<Widget> _getInitialScreen() async {
    final authService = AuthService();
    final session = await authService.getSession();

    if (session == null) {
      return const LoginPage();
    } else {
      final userService = UserService();
      final user = await userService.getUser(session.user.email!);
      if (user?.userType == 'admin') {
        return const AdminDashboard();
      } else {
        return const UserDashBoard();
      }
    }
  }
}
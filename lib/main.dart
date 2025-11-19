import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// IMPORTANT: Add this new import for screen responsiveness
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
import 'package:rkfitness/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to portrait only
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
    rethrow;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the entire app structure with ScreenUtilInit
    return ScreenUtilInit(
      // 2. Set the design size. Common Android size used here.
      // If your design document uses a specific size, use that instead.
      designSize: const Size(360, 690),
      minTextAdapt: true, // Ensures text scales down appropriately on small screens
      splitScreenMode: true, // Support for multi-window modes on some devices
      builder: (context, child) {
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
            // The home screen uses the logic to determine where to navigate
            home: const SplashScreen(),
          ),
        );
      },
    );
  }

  // NOTE: I've moved the private helper method outside the build method to keep the code clean.
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
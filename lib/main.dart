import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rkfitness/Pages/splash_screen.dart';
import 'package:rkfitness/providers/notification_provider.dart';
import 'package:rkfitness/providers/progress_provider.dart';
import 'package:rkfitness/providers/schedule_provider.dart';
import 'package:rkfitness/providers/user_provider.dart';
import 'package:rkfitness/providers/workout_provider.dart';
import 'package:rkfitness/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rkfitness/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ADDED

// NOTE: You must have defined appTheme(context) function elsewhere.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to portrait   only
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
    debugPrint('Failed to initialize Supabase client: $e');
    rethrow;
  }

  // Wrap the runApp with MultiProvider if you want the providers available immediately
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX: ScreenUtilInit must wrap the MaterialApp
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Standard Flutter project design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RKU Fitness',
          // Assuming appTheme(context) is defined in lib/theme/app_theme.dart
          theme: appTheme(context),
          home: const SplashScreen(),
        );
      },
    );
  }
}

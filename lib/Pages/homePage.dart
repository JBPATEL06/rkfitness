import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ADDED
import 'package:rkfitness/Pages/profilepage.dart';
import 'package:rkfitness/customWidgets/weekdays.dart';
import 'package:rkfitness/widgets/custom_wid_and_fun.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:rkfitness/widgets/workout_grid_item.dart';
import 'package:rkfitness/widgets/connection_status.dart';
import 'package:rkfitness/widgets/error_message.dart';
import 'package:rkfitness/widgets/loading_overlay.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rkfitness/supabaseMaster/user_progress_services.dart'; // ADDED

import '../models/user_model.dart';
import '../models/workout_table_model.dart';
import 'Notification.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = useMemoized(() => UserService());
    // ADDED: Progress Service dependency
    final progressService = useMemoized(() => UserProgressService());
    
    final isLoading = useState(false);
    final error = useState<String?>(null);
    final selectedDay = useState<Set<Days>>({getCurrentDay()});
    final hasConnection = useState(true);
    final userFuture = useState<Future<UserModel?>?>(null);
    // NEW STATE: Cache for today's completed workout IDs
    final completedWorkouts = useState<Set<String>>({});

    // Fetch user details and completed workout IDs
    useEffect(() {
      Future<void> initData() async {
        final connectivityResult = await Connectivity().checkConnectivity();
        hasConnection.value = connectivityResult != ConnectivityResult.none;
        
        final userEmail = Supabase.instance.client.auth.currentUser?.email;
        if (userEmail != null && hasConnection.value) {
          try {
            isLoading.value = true;
            error.value = null;
            userFuture.value = userService.getUser(userEmail);

            // NEW: Fetch completed workout IDs
            completedWorkouts.value = await progressService.getCompletedWorkoutIdsForToday(userEmail);

          } catch (e) {
            error.value = e.toString();
          } finally {
            isLoading.value = false;
          }
        }
      }
      
      initData();
      return null;
    }, []);

    // Memoize the workout fetching function
    final fetchTodaysWorkouts = useCallback((String? userEmail, String day) async {
      if (!hasConnection.value) {
        throw Exception('No internet connection');
      }
      
      if (userEmail == null) {
        throw Exception('Not logged in');
      }

      try {
        final response = await Supabase.instance.client
            .from('schedual workout')
            .select('*, "Workout Table"(*)')
            .eq('user_id', userEmail)
            .eq('day_of_week', day);

        if (response is! List) {
          return <WorkoutTableModel>[];
        }

        // Defensive parsing logic
        final List<WorkoutTableModel> scheduledWorkouts = (response as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((row) {
                final nestedData = row['Workout Table'];
                return nestedData is Map<String, dynamic> ? WorkoutTableModel.fromJson(nestedData) : null;
            })
            .where((workout) => workout != null)
            .cast<WorkoutTableModel>()
            .toList();
            
        // NEW FILTERING LOGIC: Remove workouts that are already in the completedWorkouts set
        final filteredWorkouts = scheduledWorkouts.where((workout) {
          // Check if the workout ID is NOT in the set of completed IDs
          return !completedWorkouts.value.contains(workout.workoutId);
        }).toList();


        return filteredWorkouts;
      } catch (e) {
        error.value = 'Data loading error: ${e.toString()}';
        return <WorkoutTableModel>[];
      }
    }, [hasConnection, completedWorkouts]); // Depend on completedWorkouts state

    Widget buildWorkoutList(String workoutType) {
      final userEmail = Supabase.instance.client.auth.currentUser?.email;
      final day = stringgetCurrentDay();
      final theme = Theme.of(context);
      
      final workoutsFuture = useMemoized(
        () => fetchTodaysWorkouts(userEmail, day),
        [userEmail, day, completedWorkouts.value] // Trigger refetch when completedWorkouts changes
      );

      return FutureBuilder<List<WorkoutTableModel>>(
        future: workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final displayError = error.value;
          if (displayError != null && displayError.isNotEmpty) {
             return Center(child: Text(displayError, style: theme.textTheme.bodyLarge));
          }

          if (snapshot.hasError) {
             return Center(child: Text('Snapshot Error: ${snapshot.error.toString()}', style: theme.textTheme.bodyLarge));
          }

          final filteredWorkouts = snapshot.data?.where((workout) {
            return workout.workoutType.toLowerCase() == workoutType;
          }).toList() ?? [];

          if (filteredWorkouts.isEmpty) {
            return Center(child: Text("No $workoutType workouts scheduled or remaining today", style: theme.textTheme.bodyLarge));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredWorkouts.length,
            itemBuilder: (context, index) {
              final workout = filteredWorkouts[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: SizedBox( 
                  width: 160.w,
                  child: WorkoutGridItem(workout: workout),
                ),
              );
            },
          );
        },
      );
    }

    Widget buildAppBar() {
      final theme = Theme.of(context);
      return SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          color: theme.colorScheme.primary,
          child: FutureBuilder<UserModel?>(
            future: userFuture.value,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: theme.colorScheme.onPrimary));
              }

              final user = snapshot.data;
              final displayName = user?.name ?? user?.gmail.split('@').first ?? 'Guest';
              final profilePicUrl = user?.profilePicture;

              return Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      ).then((_) {
                        final userEmail = Supabase.instance.client.auth.currentUser?.email;
                        if (userEmail != null) {
                          userFuture.value = userService.getUser(userEmail);
                          // Refresh the completed list when returning from profile/full workout page
                          progressService.getCompletedWorkoutIdsForToday(userEmail)
                            .then((ids) => completedWorkouts.value = ids);
                        }
                      });
                    },
                    child: CircleAvatar(
                      radius: 24.r, // CONVERTED
                      backgroundColor: Colors.grey,
                      backgroundImage: profilePicUrl != null ? NetworkImage(profilePicUrl) : null,
                      child: profilePicUrl == null
                          ? Icon(Icons.person, color: theme.colorScheme.onPrimary, size: 28.w) // CONVERTED
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.w), // CONVERTED
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Welcome,",
                          style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp)), // CONVERTED
                      Text(displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 18.sp)), // CONVERTED
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationPage()),
                        );
                      },
                      child: Icon(Icons.notifications, color: theme.colorScheme.onPrimary, size: 28.w)), // CONVERTED
                ],
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(80.h), // CONVERTED
            child: buildAppBar()),
        body: LoadingOverlay(
          isLoading: isLoading.value,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 5.h), // CONVERTED
                    Text(
                      "Schedule's Days",
                      style: TextStyle(fontSize: 20.sp), // CONVERTED
                    ),
                    SizedBox(height: 5.h), // CONVERTED
                    Weekdays(selectedDay: selectedDay.value),
                    SizedBox(height: 5.h), // CONVERTED
                    Padding(
                      padding: EdgeInsets.all(8.w), // CONVERTED
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RedText("Cardio"),
                          // TextButton removed as per original file structure, only RedText remains
                        ],
                      ),
                    ),
                    SizedBox( 
                      height: 250.h, // CONVERTED
                      child: buildWorkoutList("cardio"),
                    ),
                    SizedBox(height: 5.h), // CONVERTED
                    Padding(
                      padding: EdgeInsets.all(8.w), // CONVERTED
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RedText("Exercise"),
                          // TextButton removed as per original file structure, only RedText remains
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 250.h, // CONVERTED
                      child: buildWorkoutList("exercise"),
                    ),
                  ],
                ),
              ),
              if (error.value != null && !error.value!.contains('Data loading error'))
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 16.h,
                  left: 16.w,
                  right: 16.w,
                  child: ErrorMessage(
                    message: error.value!,
                    onRetry: () {
                      error.value = null;
                      final userEmail = Supabase.instance.client.auth.currentUser?.email;
                      if (userEmail != null) {
                        userFuture.value = userService.getUser(userEmail);
                      }
                    },
                  ),
                ),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ConnectionStatus(),
              ),
            ],
          ),
        ));
  }
}
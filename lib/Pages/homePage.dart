import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rkfitness/Pages/profilepage.dart';
import 'package:rkfitness/customWidgets/weekdays.dart';
import 'package:rkfitness/customeWidAndFun.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:rkfitness/widgets/workout_grid_item.dart';
import 'package:rkfitness/widgets/connection_status.dart';
import 'package:rkfitness/widgets/error_message.dart';
import 'package:rkfitness/widgets/loading_overlay.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/user_model.dart';
import '../models/workout_table_model.dart';
import 'Notification.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = useMemoized(() => UserService());
    final isLoading = useState(false);
    final error = useState<String?>(null);
    final selectedDay = useState<Set<Days>>({getCurrentDay()});
    final hasConnection = useState(true);
    final userFuture = useState<Future<UserModel?>?>(null);

    // Initialize data fetching
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

        if (response == null) {
          return <WorkoutTableModel>[];
        }

        final List<Map<String, dynamic>> workoutDataList = (response as List)
            .where((row) => row['Workout Table'] != null)
            .map((row) => row['Workout Table'] as Map<String, dynamic>)
            .toList();

        return workoutDataList
            .map((data) => WorkoutTableModel.fromJson(data))
            .toList();
      } catch (e) {
        error.value = e.toString();
        return <WorkoutTableModel>[];
      }
    }, [hasConnection]);

    Widget buildWorkoutList(String workoutType) {
      final userEmail = Supabase.instance.client.auth.currentUser?.email;
      final day = stringgetCurrentDay();
      final theme = Theme.of(context);
      
      final workoutsFuture = useMemoized(
        () => fetchTodaysWorkouts(userEmail, day),
        [userEmail, day]
      );

      return FutureBuilder<List<WorkoutTableModel>>(
        future: workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: theme.textTheme.bodyLarge));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No workouts for today", style: theme.textTheme.bodyLarge));
          }

          final filteredWorkouts = snapshot.data!.where((workout) {
            return workout.workoutType.toLowerCase() == workoutType;
          }).toList();

          if (filteredWorkouts.isEmpty) {
            return Center(child: Text('No $workoutType workouts today', style: theme.textTheme.bodyLarge));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredWorkouts.length,
            itemBuilder: (context, index) {
              final workout = filteredWorkouts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: WorkoutGridItem(workout: workout),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        }
                      });
                    },
                    child: CircleAvatar(
                      radius: 24.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: profilePicUrl != null ? NetworkImage(profilePicUrl) : null,
                      child: profilePicUrl == null
                          ? Icon(Icons.person, color: theme.colorScheme.onPrimary)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Welcome,",
                          style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w400)),
                      Text(displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w400)),
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
                      child: Icon(Icons.notifications, color: theme.colorScheme.onPrimary)),
                ],
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: buildAppBar()),
        body: LoadingOverlay(
          isLoading: isLoading.value,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    const Text(
                      "Schedule's Days",
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 5),
                    Weekdays(selectedDay: selectedDay.value),
                    const SizedBox(height: 5),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RedText("Cardio"),
                          TextButton(
                              onPressed: null,
                              child: Text(
                                "see all",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      child: buildWorkoutList("cardio"),
                    ),
                    const SizedBox(height: 5),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RedText("Exercise"),
                          TextButton(
                              onPressed: null,
                              child: Text(
                                "see all",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      child: buildWorkoutList("exercise"),
                    ),
                  ],
                ),
              ),
              if (error.value != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
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
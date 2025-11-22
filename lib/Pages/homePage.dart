import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:rkfitness/supabaseMaster/user_progress_services.dart';

import '../models/user_model.dart';
import '../models/workout_table_model.dart';
import 'Notification.dart';

class RedText extends StatelessWidget {
  final String text;
  const RedText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(CustomeWidAndFun().redText(text));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserService _userService = UserService();
  final UserProgressService _progressService = UserProgressService();
  final CustomeWidAndFun _myWidgets = CustomeWidAndFun(); 

  bool _isLoading = false;
  String? _error;
  late Set<Days> _selectedDay;
  bool _hasConnection = true;
  Future<UserModel?>? _userFuture;
  Set<String> _completedWorkouts = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = {_myWidgets.getCurrentDay()};
    _initData();
  }

  Future<void> _initData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _hasConnection = connectivityResult != ConnectivityResult.none;

    final userEmail = Supabase.instance.client.auth.currentUser?.email;

    if (userEmail != null && _hasConnection) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
          _userFuture = _userService.getUser(userEmail);
        });
      }

      try {
        final completedIds = await _progressService.getCompletedWorkoutIdsForToday(userEmail);
        
        if (mounted) {
          setState(() {
            _completedWorkouts = completedIds;
            _isLoading = false;
          }); 
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (!_hasConnection) {
            _error = 'No internet connection available';
          }
        });
      }
    }
  }

  Future<List<WorkoutTableModel>> _fetchTodaysWorkouts(String? userEmail, String day) async {
    if (!_hasConnection) {
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

      final List<WorkoutTableModel> scheduledWorkouts = (response as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((row) {
              final nestedData = row['Workout Table'];
              return nestedData is Map<String, dynamic> ? WorkoutTableModel.fromJson(nestedData) : null;
          })
          .where((workout) => workout != null)
          .cast<WorkoutTableModel>()
          .toList();

      final filteredWorkouts = scheduledWorkouts.where((workout) {
        return !_completedWorkouts.contains(workout.workoutId);
      }).toList();

      return filteredWorkouts;
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_error == null || !_error!.contains('Data loading error')) {
             _error = 'Data loading error: ${e.toString()}';
          }
        });
      }
      return <WorkoutTableModel>[];
    }
  }
  
  Widget _buildWorkoutList(String workoutType) {
    final userEmail = Supabase.instance.client.auth.currentUser?.email;
    final day = _myWidgets.stringgetCurrentDay(); 
    final theme = Theme.of(context);

    final workoutsFuture = _fetchTodaysWorkouts(userEmail, day);

    return FutureBuilder<List<WorkoutTableModel>>(
      future: workoutsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final displayError = _error;
        if (displayError != null && displayError.isNotEmpty && displayError.contains('Data loading error')) {
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

  Widget _buildAppBar() {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        color: theme.colorScheme.primary,
        child: FutureBuilder<UserModel?>(
          future: _userFuture,
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
                      _initData();
                    });
                  },
                  child: CircleAvatar(
                    radius: 24.r,
                    backgroundColor: Colors.grey,
                    backgroundImage: profilePicUrl != null ? NetworkImage(profilePicUrl) : null,
                    child: profilePicUrl == null
                        ? Icon(Icons.person, color: theme.colorScheme.onPrimary, size: 28.w)
                        : null,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Welcome,",
                        style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp)),
                    Text(displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 18.sp)),
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
                    child: Icon(Icons.notifications, color: theme.colorScheme.onPrimary, size: 28.w)),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(80.h),
            child: _buildAppBar()),
        body: LoadingOverlay(
          isLoading: _isLoading,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 5.h),
                    Text(
                      "Schedule's Days",
                      style: TextStyle(fontSize: 20.sp),
                    ),
                    SizedBox(height: 5.h),
                    Weekdays(selectedDay: _selectedDay),
                    SizedBox(height: 5.h),
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          RedText("Cardio"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 250.h,
                      child: _buildWorkoutList("cardio"),
                    ),
                    SizedBox(height: 5.h),
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          RedText("Exercise"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 250.h,
                      child: _buildWorkoutList("exercise"),
                    ),
                  ],
                ),
              ),
              if (_error != null && !_error!.contains('Data loading error'))
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 16.h,
                  left: 16.w,
                  right: 16.w,
                  child: ErrorMessage(
                    message: _error!,
                    compact: true,
                    onRetry: () {
                      if (mounted) {
                        setState(() {
                          _error = null;
                        });
                      }
                      _initData();
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
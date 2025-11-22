import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rkfitness/AdminMaster/admin_profile.dart';
import 'package:rkfitness/AdminMaster/admin_notification.dart';
import 'package:rkfitness/Pages/workoutPage.dart';
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:rkfitness/supabaseMaster/workout_services.dart';
import 'package:rkfitness/widgets/custom_wid_and_fun.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final CustomeWidAndFun mywidget = CustomeWidAndFun();
  final UserService _userService = UserService();
  final WorkoutTableService _workoutService = WorkoutTableService();
  late Future<Map<String, dynamic>> _adminDataFuture;

  @override
  void initState() {
    super.initState();
    _adminDataFuture = _fetchAdminData();
  }

  Future<Map<String, dynamic>> _fetchAdminData() async {
    final adminEmail = Supabase.instance.client.auth.currentUser?.email;
    if (adminEmail == null) {
      return Future.value({});
    }

    final adminFuture = _userService.getUser(adminEmail);
    final allUsersFuture = _userService.getAllUsers();
    final totalCardioFuture = _workoutService.getWorkoutCountByType('cardio');
    final totalExerciseFuture =
        _workoutService.getWorkoutCountByType('exercise');
    final cardioWorkoutsFuture = _fetchRecentWorkouts('cardio');
    final exerciseWorkoutsFuture = _fetchRecentWorkouts('exercise');

    final results = await Future.wait([
      adminFuture,
      allUsersFuture,
      totalCardioFuture,
      totalExerciseFuture,
      cardioWorkoutsFuture,
      exerciseWorkoutsFuture,
    ]);

    final List<UserModel> allUsers = results[1] as List<UserModel>;
    
    // --- BMI Categorization Logic ---
    int normalCount = 0; // Good (18.5 - 24.9)
    int averageCount = 0; // Average (< 18.5 or 25.0 - 29.9)
    int worstCount = 0; // Worst (>= 30.0)

    for (var user in allUsers) {
        final bmi = user.bmi;
        if (bmi != null) {
            if (bmi >= 18.5 && bmi <= 24.9) {
                normalCount++;
            } else if (bmi < 18.5 || (bmi >= 25.0 && bmi < 30.0)) {
                averageCount++;
            } else if (bmi >= 30.0) {
                worstCount++;
            }
        }
    }
    final categorizedCount = normalCount + averageCount + worstCount;
    // ------------------------------------

    return {
      'admin': results[0] as UserModel?,
      'totalUsers': allUsers.length,
      'totalCardio': results[2] as int,
      'totalExercise': results[3] as int,
      'cardioWorkouts': results[4] as List<WorkoutTableModel>,
      'exerciseWorkouts': results[5] as List<WorkoutTableModel>,
      'goodUsers': normalCount,
      'averageUsers': averageCount,
      'worstUsers': worstCount,
      'categorizedCount': categorizedCount,
    };
  }

  Future<List<WorkoutTableModel>> _fetchRecentWorkouts(String type) async {
    try {
      final response = await Supabase.instance.client
          .from('Workout Table')
          .select()
          .eq('Workout type', type)
          .limit(5);
      return (response as List)
          .map((w) => WorkoutTableModel.fromJson(w))
          .toList();
    } catch (e) {
      print('Error fetching recent workouts: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<Map<String, dynamic>>(
      future: _adminDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Error loading data.'));
        }

        final data = snapshot.data!;
        final UserModel? admin = data['admin'];
        final int totalUsers = data['totalUsers'];
        final int totalCardio = data['totalCardio'];
        final int totalExercise = data['totalExercise'];
        final List<WorkoutTableModel> cardioWorkouts =
            data['cardioWorkouts'];
        final List<WorkoutTableModel> exerciseWorkouts =
            data['exerciseWorkouts'];
        final int goodUsers = data['goodUsers'];
        final int averageUsers = data['averageUsers'];
        final int worstUsers = data['worstUsers'];
        final int categorizedCount = data['categorizedCount'];


        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false, // FIX: Removes the unexpected back arrow
            toolbarHeight: 80.h,
            backgroundColor: theme.colorScheme.primary,
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AdminProfilePage()),
                          );
                        },
                        child: CircleAvatar(
                          radius: 25.r,
                          backgroundColor: Colors.white,
                          backgroundImage: admin?.profilePicture != null
                              ? NetworkImage(admin!.profilePicture!)
                              : null,
                          child: admin?.profilePicture == null
                              ? Icon(Icons.person, color: Colors.grey.shade600, size: 30.w)
                              : null,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome,',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white)),
                          Text(admin?.name ?? 'Admin',
                              style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const SendNotificationPage()),
                        );
                      },
                      child: Icon(Icons.notifications,
                          color: Colors.white, size: 30.w)),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                          context, 'Total Users', totalUsers, Icons.people),
                      _buildStatCard(context, 'Total Cardio', totalCardio,
                          Icons.fitness_center),
                      _buildStatCard(context, 'Total Exercise',
                          totalExercise, Icons.sports_gymnastics),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'User Stats (Based on BMI)',
                    style:
                        theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),
                  _buildUserChart(theme, goodUsers, averageUsers, worstUsers, categorizedCount),
                  SizedBox(height: 20.h),
                  _buildWorkoutSection(context, 'Cardio', cardioWorkouts),
                  SizedBox(height: 20.h),
                  _buildWorkoutSection(
                      context, 'Exercise', exerciseWorkouts),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, int value, IconData icon) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Text('$value',
                  style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary)),
              Icon(icon, color: theme.colorScheme.primary),
              SizedBox(height: 5.h),
              Text(title, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserChart(ThemeData theme, int good, int average, int worst, int total) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: _buildChartSections(theme, good, average, worst, total),
                    sectionsSpace: 2.w,
                    centerSpaceRadius: 40.r,
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegend('Good (BMI 18.5-24.9)', Colors.orange),
                  _buildLegend('Average (Under/Overweight)', Colors.purple),
                  _buildLegend('Worst (Obese)', theme.colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections(ThemeData theme, int good, int average, int worst, int total) {
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          title: '0%',
          radius: 60.r,
          titleStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ];
    }
    
    final double goodPercent = (good / total) * 100;
    final double averagePercent = (average / total) * 100;
    final double worstPercent = (worst / total) * 100;
    
    return [
      PieChartSectionData(
        color: Colors.orange,
        value: goodPercent,
        title: '${goodPercent.toStringAsFixed(1)}%',
        radius: 60.r,
        titleStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: averagePercent,
        title: '${averagePercent.toStringAsFixed(1)}%',
        radius: 60.r,
        titleStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: theme.colorScheme.primary,
        value: worstPercent,
        title: '${worstPercent.toStringAsFixed(1)}%',
        radius: 60.r,
        titleStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  Widget _buildLegend(String title, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(width: 16.w, height: 16.w, color: color),
          SizedBox(width: 8.w),
          Text(title, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildWorkoutSection(BuildContext context, String title,
      List<WorkoutTableModel> workouts) {
    final theme = Theme.of(context);
    final listHeight = 250.h; 
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(mywidget.redText(title)),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutPage()
                  ),
                );
              },
              child: Text('see all', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: listHeight,
          child: workouts.isEmpty
              ? Center(child: Text('No $title workouts found.', style: theme.textTheme.bodyLarge))
              : SizedBox(
                    height: listHeight,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final workoutData = workouts[index];
                        return mywidget.workout(context, workoutData); 
                      },
                    ),
                  ),
        ),
      ],
    );
  }
}
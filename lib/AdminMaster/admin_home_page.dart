import 'package:flutter/material.dart';
// ADDED import for screenutil extensions (.w, .h, .sp, .r)
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rkfitness/AdminMaster/admin_profile.dart';
import 'package:rkfitness/AdminMaster/admin_notification.dart';
import 'package:rkfitness/Pages/workoutPage.dart';
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:rkfitness/supabaseMaster/workout_services.dart';
import 'package:rkfitness/widgets/custom_widgets.dart';
// REMOVED: import 'package:rkfitness/utils/responsive.dart';
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
    final totalUsersFuture = _userService.getAllUsers();
    final totalCardioFuture = _workoutService.getWorkoutCountByType('cardio');
    final totalExerciseFuture =
        _workoutService.getWorkoutCountByType('exercise');
    final cardioWorkoutsFuture = _fetchRecentWorkouts('cardio');
    final exerciseWorkoutsFuture = _fetchRecentWorkouts('exercise');

    final results = await Future.wait([
      adminFuture,
      totalUsersFuture,
      totalCardioFuture,
      totalExerciseFuture,
      cardioWorkoutsFuture,
      exerciseWorkoutsFuture,
    ]);

    return {
      'admin': results[0] as UserModel?,
      'totalUsers': (results[1] as List<UserModel>).length,
      'totalCardio': results[2] as int,
      'totalExercise': results[3] as int,
      'cardioWorkouts': results[4] as List<WorkoutTableModel>,
      'exerciseWorkouts': results[5] as List<WorkoutTableModel>,
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

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 80.h, // CONVERTED
            backgroundColor: theme.colorScheme.primary,
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w), // CONVERTED
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
                          radius: 25.r, // CONVERTED
                          backgroundColor: Colors.white,
                          backgroundImage: admin?.profilePicture != null
                              ? NetworkImage(admin!.profilePicture!)
                              : null,
                          child: admin?.profilePicture == null
                              ? Icon(Icons.person, color: Colors.grey.shade600, size: 30.w) // CONVERTED
                              : null,
                        ),
                      ),
                      SizedBox(width: 10.w), // CONVERTED
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
                          color: Colors.white, size: 30.w)), // CONVERTED
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.w), // CONVERTED
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
                  SizedBox(height: 20.h), // CONVERTED
                  Text(
                    'User Stats',
                    style:
                        theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h), // CONVERTED
                  _buildUserChart(theme),
                  SizedBox(height: 20.h), // CONVERTED
                  _buildWorkoutSection(context, 'Cardio', cardioWorkouts),
                  SizedBox(height: 20.h), // CONVERTED
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)), // CONVERTED
        child: Padding(
          padding: EdgeInsets.all(16.w), // CONVERTED
          child: Column(
            children: [
              Text('$value',
                  style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary)),
              Icon(icon, color: theme.colorScheme.primary),
              SizedBox(height: 5.h), // CONVERTED
              Text(title, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserChart(ThemeData theme) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)), // CONVERTED
        child: Padding(
          padding: EdgeInsets.all(16.w), // CONVERTED
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: _buildChartSections(theme),
                    sectionsSpace: 2.w, // CONVERTED
                    centerSpaceRadius: 40.r, // CONVERTED
                  ),
                ),
              ),
              SizedBox(width: 20.w), // CONVERTED
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegend('Good', Colors.orange),
                  _buildLegend('Average', Colors.purple),
                  _buildLegend('Worst', theme.colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections(ThemeData theme) {
    return [
      PieChartSectionData(
        color: Colors.orange,
        value: 50,
        title: '50.0%',
        radius: 60.r, // CONVERTED
        titleStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: 26.7,
        title: '26.7%',
        radius: 60.r, // CONVERTED
        titleStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: theme.colorScheme.primary,
        value: 23.3,
        title: '23.3%',
        radius: 60.r, // CONVERTED
        titleStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  Widget _buildLegend(String title, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h), // CONVERTED
      child: Row(
        children: [
          Container(width: 16.w, height: 16.w, color: color), // CONVERTED to square proportional to width
          SizedBox(width: 8.w), // CONVERTED
          Text(title, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildWorkoutSection(BuildContext context, String title,
      List<WorkoutTableModel> workouts) {
    final theme = Theme.of(context);
    // Determine the desired height for the list view (e.g., 35% of 690 design height)
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
        SizedBox(height: 10.h), // CONVERTED
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
                        // The workout widget uses its internal responsiveness now
                        return mywidget.workout(context, workoutData); 
                      },
                    ),
                  ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rkfitness/AdminMaster/admin_profile.dart';
import 'package:rkfitness/AdminMaster/admin_notification.dart';
import 'package:rkfitness/Pages/workoutPage.dart';
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:rkfitness/supabaseMaster/workout_services.dart';
import 'package:rkfitness/widgets/custom_widgets.dart';
import 'package:rkfitness/utils/responsive.dart';
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
            toolbarHeight: 80,
            backgroundColor: theme.colorScheme.primary,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                          backgroundColor: Colors.white,
                          backgroundImage: admin?.profilePicture != null
                              ? NetworkImage(admin!.profilePicture!)
                              : null,
                          child: admin?.profilePicture == null
                              ? Icon(Icons.person, color: Colors.grey.shade600)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
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
                      child: const Icon(Icons.notifications,
                          color: Colors.white, size: 30)),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                  const SizedBox(height: 20),
                  Text(
                    'User Stats',
                    style:
                        theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildUserChart(theme),
                  const SizedBox(height: 20),
                  _buildWorkoutSection(context, 'Cardio', cardioWorkouts),
                  const SizedBox(height: 20),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('$value',
                  style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary)),
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 5),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: _buildChartSections(theme),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(width: 20),
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
        radius: 60,
        titleStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: 26.7,
        title: '26.7%',
        radius: 60,
        titleStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: theme.colorScheme.primary,
        value: 23.3,
        title: '23.3%',
        radius: 60,
        titleStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  Widget _buildLegend(String title, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 16, height: 16, color: color),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildWorkoutSection(BuildContext context, String title,
      List<WorkoutTableModel> workouts) {
    final theme = Theme.of(context);
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
        const SizedBox(height: 10),
        SizedBox(
          height: Responsive.responsiveHeight(context, 35),
          child: workouts.isEmpty
              ? Center(child: Text('No $title workouts found.', style: theme.textTheme.bodyLarge))
              : SizedBox(
                    height: Responsive.responsiveHeight(context, 30),
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
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
    final double scale = Responsive.getProportionateScreenWidth(context, 1);
    
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
            // Responsive toolbar height
            toolbarHeight: Responsive.getProportionateScreenHeight(context, 80),
            backgroundColor: theme.colorScheme.primary,
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.getProportionateScreenWidth(context, 16.0)),
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
                          // Responsive avatar radius
                          radius: Responsive.getProportionateScreenWidth(context, 24),
                          backgroundColor: Colors.white,
                          backgroundImage: admin?.profilePicture != null
                              ? NetworkImage(admin!.profilePicture!)
                              : null,
                          child: admin?.profilePicture == null
                              ? Icon(Icons.person, color: Colors.grey.shade600, size: Responsive.getProportionateScreenWidth(context, 30))
                              : null,
                        ),
                      ),
                      SizedBox(width: Responsive.getProportionateScreenWidth(context, 10)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome,',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontSize: 14 * scale)), // Scaled
                          Text(admin?.name ?? 'Admin',
                              style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18 * scale)), // Scaled
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
                          color: Colors.white, size: 30 * scale)), // Scaled
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            // Responsive padding
            padding: EdgeInsets.all(Responsive.getProportionateScreenWidth(context, 16.0)),
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
                SizedBox(height: Responsive.getProportionateScreenHeight(context, 20)),
                Text(
                  'User Stats',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 20 * scale), // Scaled
                ),
                SizedBox(height: Responsive.getProportionateScreenHeight(context, 10)),
                _buildUserChart(theme),
                SizedBox(height: Responsive.getProportionateScreenHeight(context, 20)),
                _buildWorkoutSection(context, 'Cardio', cardioWorkouts),
                SizedBox(height: Responsive.getProportionateScreenHeight(context, 20)),
                _buildWorkoutSection(
                    context, 'Exercise', exerciseWorkouts),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, int value, IconData icon) {
    final theme = Theme.of(context);
    final double scale = Responsive.getProportionateScreenWidth(context, 1);
    
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.getProportionateScreenWidth(context, 10))), // Scaled radius
        child: Padding(
          padding: EdgeInsets.all(Responsive.getProportionateScreenWidth(context, 16.0)), // Scaled padding
          child: Column(
            children: [
              Text('$value',
                  style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 32 * scale)), // Scaled font size
              Icon(icon, color: theme.colorScheme.primary, size: 24 * scale), // Scaled icon size
              SizedBox(height: 5 * scale), // Scaled height
              Text(title, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14 * scale)), // Scaled font size
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserChart(ThemeData theme) {
    final double scale = Responsive.getProportionateScreenWidth(context, 1);
    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.getProportionateScreenWidth(context, 10))), // Scaled radius
        child: Padding(
          padding: EdgeInsets.all(Responsive.getProportionateScreenWidth(context, 16.0)), // Scaled padding
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: _buildChartSections(theme),
                    sectionsSpace: Responsive.getProportionateScreenWidth(context, 2), // Scaled space
                    centerSpaceRadius: Responsive.getProportionateScreenWidth(context, 40), // Scaled radius
                  ),
                ),
              ),
              SizedBox(width: Responsive.getProportionateScreenWidth(context, 20)), // Scaled width
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
    final double scale = Responsive.getProportionateScreenWidth(context, 1);
    // Use scale for radius and title size
    final double radius = 60 * scale; 
    final double titleSize = 16 * scale;
    
    return [
      PieChartSectionData(
        color: Colors.orange,
        value: 50,
        title: '50.0%',
        radius: radius,
        titleStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: titleSize),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: 26.7,
        title: '26.7%',
        radius: radius,
        titleStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: titleSize),
      ),
      PieChartSectionData(
        color: theme.colorScheme.primary,
        value: 23.3,
        title: '23.3%',
        radius: radius,
        titleStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: titleSize),
      ),
    ];
  }

  Widget _buildLegend(String title, Color color) {
    final theme = Theme.of(context);
    final double scale = Responsive.getProportionateScreenWidth(context, 1);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0 * scale), // Scaled padding
      child: Row(
        children: [
          Container(width: 16 * scale, height: 16 * scale, color: color), // Scaled size
          SizedBox(width: 8 * scale), // Scaled width
          Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14 * scale)), // Scaled font size
        ],
      ),
    );
  }

  Widget _buildWorkoutSection(BuildContext context, String title,
      List<WorkoutTableModel> workouts) {
    final theme = Theme.of(context);
    final double scale = Responsive.getProportionateScreenWidth(context, 1);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(mywidget.redText(title)), 
            TextButton(
              onPressed: () {
                // Navigate to the main WorkoutPage which has the tabs
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkoutPage()
                  ),
                );
              },
              child: Text('see all', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey, fontSize: 14 * scale)), // Scaled font size
            ),
          ],
        ),
        SizedBox(height: 10 * scale), // Scaled height
        SizedBox(
          // Use proportional height for the list container
          height: Responsive.responsiveHeight(context, 35),
          child: workouts.isEmpty
              ? Center(child: Text('No $title workouts found.', style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16 * scale))) // Scaled font size
              : SizedBox(
                    // Inner SizedBox with correct proportional height
                    height: Responsive.responsiveHeight(context, 30),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final workoutData = workouts[index];
                        // The mywidget.workout already handles responsive sizing internally
                        return mywidget.workout(context, workoutData); 
                      },
                    ),
                  ),
        ),
      ],
    );
  }
}
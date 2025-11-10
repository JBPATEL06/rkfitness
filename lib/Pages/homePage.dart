import 'package:flutter/material.dart';
import 'package:rkfitness/Pages/profilepage.dart';
import 'package:rkfitness/customWidgets/weekdays.dart';
import 'package:rkfitness/customeWidAndFun.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../models/workout_table_model.dart';
import 'Notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserService _userService = UserService();
  late Future<UserModel?> _userFuture;

  Set<Days> _selectedDay = {};
  CustomeWidAndFun mywidget = CustomeWidAndFun();

  @override
  void initState() {
    super.initState();
    _selectedDay = {mywidget.getCurrentDay()};
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final userEmail = Supabase.instance.client.auth.currentUser?.email;
    if (userEmail != null) {
      _userFuture = _userService.getUser(userEmail);
    } else {
      _userFuture = Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: rkuAppBar(context)),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 5),
              const Text(
                "Schedule's Days",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 5,
              ),
              Weekdays(
                selectedDay: _selectedDay,
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(mywidget.redText("Cardio")),
                    TextButton(
                        onPressed: null,
                        child: const Text(
                          "see all",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ))
                  ],
                ),
              ),
              SizedBox(
                height: 250,
                child: _buildWorkoutList("cardio"),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(mywidget.redText("Exercise")),
                    TextButton(
                        onPressed: null,
                        child: const Text(
                          "see all",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ))
                  ],
                ),
              ),
              SizedBox(
                height: 250,
                child: _buildWorkoutList("exercise"),
              ),
            ],
          ),
        ));
  }

  Widget rkuAppBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.red[800],
        child: FutureBuilder<UserModel?>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = snapshot.data;
            final userEmail = user?.gmail.split('@').first ?? 'Guest';
            final profilePicUrl = user?.profilePicture;

            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 24.0,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                    profilePicUrl != null ? NetworkImage(profilePicUrl) : null,
                    child: profilePicUrl == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Welcome,",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w400)),
                    Text(userEmail,
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationPage()),
                      );
                    },
                    child: const Icon(Icons.notifications, color: Colors.white)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWorkoutList(String workoutType) {
    final userEmail = Supabase.instance.client.auth.currentUser?.email;
    final day = mywidget.stringgetCurrentDay();

    return FutureBuilder<List<WorkoutTableModel>>(
      future: _fetchTodaysWorkouts(userEmail, day),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No workouts for today"));
        }

        final filteredWorkouts = snapshot.data!.where((workout) {
          return workout.workoutType.toLowerCase() == workoutType;
        }).toList();

        if (filteredWorkouts.isEmpty) {
          return Center(child: Text('No $workoutType workouts today'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filteredWorkouts.length,
          itemBuilder: (context, index) {
            final workout = filteredWorkouts[index];
            // CORRECTED: Pass the entire workout object
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: mywidget.workout12(context, workout),
            );
          },
        );
      },
    );
  }

  Future<List<WorkoutTableModel>> _fetchTodaysWorkouts(
      String? userEmail, String day) async {
    if (userEmail == null) {
      return [];
    }
    try {
      final response = await Supabase.instance.client
          .from('schedual workout')
          .select('*, "Workout Table"(*)')
          .eq('user_id', userEmail)
          .eq('day_of_week', day);

      if (response.isEmpty) {
        return [];
      }

      final List<Map<String, dynamic>> workoutDataList = (response as List)
          .map((row) => row['Workout Table'] as Map<String, dynamic>)
          .toList();

      return workoutDataList
          .map((data) => WorkoutTableModel.fromJson(data))
          .toList();
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
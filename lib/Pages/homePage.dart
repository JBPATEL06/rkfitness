// home_page.dart (updated code)

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rkfitness/Pages/profilepage.dart';
import 'package:rkfitness/customWidgets/weekdays.dart';
import 'package:rkfitness/customeWidAndFun.dart';
import 'package:rkfitness/models/scheduled_workout_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../models/workout_table_model.dart'; // Import your WorkoutTableModel
import 'Notification.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePage();

}
class _HomePage extends State<HomePage>{

  Set<Days> _selectedDay = {};
  CustomeWidAndFun mywidget = new CustomeWidAndFun();
  String tempImageUrl = "https://www.gifss.com/deportes/atletismo/images/atleta-26.gif";
  void initState() {
    super.initState();
    _selectedDay = {mywidget.getCurrentDay()};
  }
  Widget build(BuildContext context){
    final userEmail = Supabase.instance.client.auth.currentUser?.email ?? 'Guest';

    return Scaffold(
        appBar: PreferredSize(preferredSize: Size.fromHeight(100) ,
            child: rkuAppBar(context, userEmail)),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 5),
              Text("Scheduel's Days",style: TextStyle(fontSize: 20),),
              SizedBox(height: 5,),
              Weekdays(
                selectedDay: _selectedDay,
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[ Text.rich(
                      mywidget.redText("Cardio")
                  ),
                    TextButton(onPressed: null, child: Text("see all",style: TextStyle(
                        fontSize: 16,
                        color: Colors.black
                    ),))
                  ],
                ),
              ),
              SizedBox(
                height: 250,
                child: Expanded(
                  child: _buildWorkoutList("Cardio"),
                ),
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Text.rich(
                        mywidget.redText("Exercise")
                    ),
                    TextButton(onPressed: null, child: Text("see all",style: TextStyle(
                        fontSize: 16,
                        color: Colors.black
                    ),))
                  ],
                ),
              ),
              SizedBox(
                height: 250,
                child: _buildWorkoutList("Exercise"),
              ),
            ],
          ),
        )
    );
  }
  //App bar Created by  Jeel
  Widget rkuAppBar(BuildContext context, String userEmail) {
    String _ProfilePic =
        "https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE";

    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.red[800],
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the ProfilePage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: CircleAvatar(
                radius: 24.0,
                backgroundColor: Colors.grey,
                child: ClipOval(
                  child: Image.network(
                    _ProfilePic,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,

                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Icon(Icons.person);
                    },
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Welcome ,",
                    style: TextStyle(
                        fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400)),
                Text(userEmail,
                    style: TextStyle(
                        fontSize: 18, color: Colors.white, fontWeight: FontWeight.w400)),
              ],
            ),
            Spacer(), // pushes icon to right
            GestureDetector(
                onTap: () {
                  // Navigate to the ProfilePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationPage()),
                  );
                },
                child: Icon(Icons.notifications, color: Colors.white)),

          ],
        ),
      ),
    );
  }

  // This is the new widget to build the list view for a given workout type
  Widget _buildWorkoutList(String workoutType) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final day = mywidget.stringgetCurrentDay();

    return FutureBuilder<List<WorkoutTableModel>>(
      future: _fetchTodaysWorkouts(userId, day),
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

        // Filter workouts by the specified type
        final filteredWorkouts = snapshot.data!.where((workout) {
          return workout.workoutType == workoutType;
        }).toList();

        if (filteredWorkouts.isEmpty) {
          return Center(child: Text('No $workoutType workouts today'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filteredWorkouts.length,
          itemBuilder: (context, index) {
            final workout = filteredWorkouts[index];
            final gifUrl = Supabase.instance.client.storage
                .from('image_and_gifs')
                .getPublicUrl(workout.gifPath ?? '');

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: mywidget.workout(
                context,
                gifUrl,
                workout.workoutName,
              ),
            );
          },
        );
      },
    );
  }

  Future<List<WorkoutTableModel>> _fetchTodaysWorkouts(String? userId, String day) async {
    if (userId == null) {
      return [];
    }
    try {
      // 1. Fetch scheduled workout IDs using ScheduleWorkoutModel
      final scheduleResponse = await Supabase.instance.client
          .from('schedul workout table')
          .select()
          .filter('user_id', 'eq', userId)
          .filter('day_of_week', 'eq', day)
          .order('order_in_day');

      if (scheduleResponse.isEmpty) {
        return [];
      }

      final workoutIds = scheduleResponse.map((row) => ScheduleWorkoutModel.fromJson(row).workoutId).toList();

      // 2. Fetch workout details using WorkoutTableModel
      final workoutResponse = await Supabase.instance.client
          .from('Workout Table')
          .select()
          .filter('Workout id', 'in', '(${workoutIds.map((id) => '"$id"').join(',')})');

      if (workoutResponse.isEmpty) {
        return [];
      }

      // 3. Convert fetched data to WorkoutTableModel objects
      final List<WorkoutTableModel> workouts = workoutResponse.map((data) => WorkoutTableModel.fromJson(data)).toList();
      return workouts;

    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
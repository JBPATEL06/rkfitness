import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rkfitness/customWidgets/weekdays.dart';
import 'package:rkfitness/customeWidAndFun.dart';
import 'package:rkfitness/models/scheduled_workout_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePage();

}
class _HomePage extends State<HomePage>{

  Set<Days> _selectedDay = {};
  CustomeWidAndFun mywidget = new CustomeWidAndFun();
  String tempImageUrl = "https://tenor.com/view/supino-gif-1051970891886466370";
  void initState() {
    super.initState();
    _selectedDay = {mywidget.getCurrentDay()};
  }
  Widget build(BuildContext context){
    return Scaffold(
    appBar: PreferredSize(preferredSize: Size.fromHeight(100) ,
        child: rkuAppBar(context)),
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

                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                      itemBuilder: (context,index)
                  {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: mywidget.workout(context,tempImageUrl, "exerciseName"),
                    );
                  }
                  ),
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
             child: workoutStream(context),
                // child: ListView.builder(
                //     scrollDirection: Axis.horizontal,
                //     itemCount: 5,
                //     itemBuilder: (context,index)
                //     {
                //       return Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //         child: mywidget.workout(context,tempImageUrl, "exerciseName"),
                //       );
                //     }
                // ),
              ),
            ],
          ),
        )
    );
  }
  //App bar Created by  Jeel
  Widget rkuAppBar(BuildContext context) {
    String _ProfilePic =
        "https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE";

    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.red[800],
        child: Row(
          children: [
            CircleAvatar(
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
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Welcome ,",
                    style: TextStyle(
                        fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400)),
                Text("_UserName",
                    style: TextStyle(
                        fontSize: 18, color: Colors.white, fontWeight: FontWeight.w400)),
              ],
            ),
            Spacer(), // pushes icon to right
            Icon(Icons.notifications, color: Colors.white),

          ],
        ),
      ),
    );
  }


// Widget excesizeGrid(BuildContext context)
// {

//   Days day = mywidget.getCurrentDay();
//   final userId = Supabase.instance.client.auth.currentUser?.id;
//   return StreamBuilder(
//     stream: Supabase.instance.client
//       .from('"schedual workout"') // <-- wrap table name in quotes
//       .stream(primaryKey: ['id'])
//       .eq('user_id', userId)
//       .eq('day_of_week', day),
//     builder: (context , snapshot)
//     {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data! == null) {
//             return const Center(child: Text('No exercise Found'));
//           }

//           final workouts = snapshot.data!;
//            return GridView.builder(
//             padding: const EdgeInsets.all(16),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.6,
//               mainAxisSpacing: 10,
//               crossAxisSpacing: 10,
//             ),
//             itemCount: workouts.length,
//             itemBuilder: (context, index) {
//               final workoutsIndex = workouts[index];
//               return mywidget.workout(context, workoutsIndex['Gif Path'] , workoutsIndex['Workout Name']);
//             }
//           );
//     }
  
//   );
// }
Widget workoutStream(BuildContext context) {
  final userEmail = Supabase.instance.client.auth.currentUser?.email ?? '';
  final day = mywidget.stringgetCurrentDay();

  return FutureBuilder<List<Map<String, dynamic>>>(
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

      final rows = snapshot.data!;

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];
          
          return mywidget.workout(
            context,
            row['Gif Path'] ?? '',
            row['Workout Name'] ?? '',
          );
        },
      );
    },
  );
}

Future<List<Map<String, dynamic>>> _fetchTodaysWorkouts(String email, String day) async {
  try {
    // Get scheduled workouts for user and day
    final scheduleResponse = await Supabase.instance.client
        .from('schedual workout')
        .select('workout_id, order_in_day')
        .filter('user_id', 'eq',email )
        .filter('day_of_week', 'eq', day)
        .order('order_in_day');

    if (scheduleResponse.isEmpty) {
      return [];
    }

    // Get all workout details
    final workoutIds = scheduleResponse.map((row) => row['workout_id']).toList();
    final workoutResponse = await Supabase.instance.client
        .from('Workout Table')
        .select('*')
        .filter('Workout id', 'in', '(${workoutIds.map((id) => '"$id"').join(',')})');

    // Combine data maintaining order
    final combinedData = <Map<String, dynamic>>[];
    for (final schedule in scheduleResponse) {
      final workoutId = schedule['workout_id'];
      final workout = workoutResponse.firstWhere(
        (w) => w['Workout id'] == workoutId,
        orElse: () => <String, dynamic>{},
      );
      
      if (workout.isNotEmpty) {
        combinedData.add(workout);
      }
    }

    return combinedData;
  } catch (e) {
    print('Error: $e');
    return [];
  }
}
// mywidget.workout(tempImageUrl,"Jeel"),
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rkfitness/AdminMaster/adminEditWorkout.dart';
import 'package:rkfitness/Pages/fullWorkout.dart';
import 'package:rkfitness/models/workout_table_model.dart'; // Import the model
import 'package:supabase_flutter/supabase_flutter.dart';

import 'customWidgets/weekdays.dart';

class CustomeWidAndFun {
  // UPDATED: This widget is now fully dynamic
  Widget workout12(BuildContext context, WorkoutTableModel workout) {
    final gifUrl = workout.gifPath != null
        ? Supabase.instance.client.storage
        .from('image_and_gifs')
        .getPublicUrl(workout.gifPath!)
        : 'https://via.placeholder.com/150'; // Fallback URL

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FullWorkoutPage(
                workout: workout, // Pass the whole workout object
              )),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          height: phoneHieght(context) * 0.40,
          width: phoneWidth(context) * 0.45,
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: NetworkImage(gifUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  workout.workoutName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan redText(String text) {
    if (text.isEmpty) {
      return const TextSpan(text: '');
    }
    return TextSpan(
      children: [
        TextSpan(
          text: text[0],
          style: const TextStyle(
            color: Colors.red,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: text.substring(1),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Days getCurrentDay() {
    int weekday = DateTime.now().weekday;
    return Days.values[weekday - 1];
  }

  String stringgetCurrentDay() {
    DateTime now = DateTime.now();
    return DateFormat('EEE')
        .format(now)
        .toUpperCase();
  }

  double phoneHieght(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double phoneWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // UPDATED: This widget is now fully dynamic
  Widget workout(BuildContext context, WorkoutTableModel workout) {
    final gifUrl = workout.gifPath != null
        ? Supabase.instance.client.storage
        .from('image_and_gifs')
        .getPublicUrl(workout.gifPath!)
        : 'https://via.placeholder.com/150'; // Fallback URL

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FullWorkoutPage(
                workout: workout, // Pass the whole workout object
              )),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
              height: phoneHieght(context) * 0.30,
              width: phoneWidth(context) * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.white,
                image: DecorationImage(
                  image: NetworkImage(gifUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      workout.workoutName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.red),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditWorkoutPage(
                          workoutToEdit:
                          workout, // Pass the workout object to the edit page
                        )),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
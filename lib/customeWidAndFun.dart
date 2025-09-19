import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rkfitness/AdminMaster/adminEditWorkout.dart';
import 'package:rkfitness/Pages/fullWorkout.dart';

import 'Pages/homePage.dart';
import 'customWidgets/weekdays.dart';
class CustomeWidAndFun {

  //Widget created by Dhruvil for show workout in mini container
  Widget workout12(BuildContext context,String imagePath, String exerciseName) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FullWorkoutPage(workoutGifUrl: "https://www.gifss.com/deportes/atletismo/images/atleta-26.gif", workoutName: "workoutName", description: "description", category: "category")),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          height: phoneHieght(context)*0.40,
          width: phoneWidth(context)*0.45,
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: NetworkImage(imagePath),
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
                  exerciseName,
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

  // Created by Dhruvil for get red color on first letter of text
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
            fontSize: 24, // Example font size
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

  //created by jeel for get current day from the user
  Days getCurrentDay() {
    int weekday = DateTime.now().weekday;

    return Days.values[weekday - 1];
  }

  String stringgetCurrentDay() {
    DateTime now = DateTime.now();
    return DateFormat('EEEE').format(now); // returns full day name like "Monday"
  }

  double phoneHieght(BuildContext context){
    double devicehieght = MediaQuery.of(context).size.height;
    return devicehieght;
  }
  double phoneWidth(BuildContext context){
    double deviceWidth = MediaQuery.of(context).size.width;
    return deviceWidth;
  }

// Assuming you have these helper functions defined elsewhere
// double phoneHieght(BuildContext context) => MediaQuery.of(context).size.height;
// double phoneWidth(BuildContext context) => MediaQuery.of(context).size.width;

  Widget workout(BuildContext context, String imagePath, String exerciseName) {
    WorkoutItem editWorkout = WorkoutItem(name: "name", type: "type", duration: "duration", category: "category", reps: "5", sets: "3", description: "description");
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FullWorkoutPage(workoutGifUrl: "https://www.gifss.com/deportes/atletismo/images/atleta-26.gif", workoutName: "workoutName", description: "description", category: "category")),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            // The main container for the workout card
            Container(
              height: phoneHieght(context) * 0.40,
              width: phoneWidth(context) * 0.45,
              decoration: BoxDecoration(
                color: Colors.white70,
                image: DecorationImage(
                  image: NetworkImage(imagePath),
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
                      exerciseName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // The edit button in the top-right corner
            Positioned(
              top: 8.0,
              right: 8.0,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.red),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  EditWorkoutPage(workoutToEdit: editWorkout)),
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

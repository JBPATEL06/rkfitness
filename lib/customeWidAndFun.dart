import 'package:flutter/material.dart';

import 'Pages/homePage.dart';
import 'customWidgets/weekdays.dart';
class CustomeWidAndFun {

  //Widget created by Dhruvil for show workout in mini container
  Widget workout(String imagePath, String exerciseName) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        height: 250,
        width: 200,
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
  double phoneHieght(BuildContext context){
    double devicehieght = MediaQuery.of(context).size.height;
    return devicehieght;
  }
  double phoneWidth(BuildContext context){
    double deviceWidth = MediaQuery.of(context).size.width;
    return deviceWidth;
  }

}
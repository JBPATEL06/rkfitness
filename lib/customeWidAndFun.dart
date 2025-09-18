import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Pages/homePage.dart';
import 'customWidgets/weekdays.dart';
class CustomeWidAndFun {

  //Widget created by Dhruvil for show workout in mini container
  Widget workout(BuildContext context,String imagePath, String exerciseName) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        height: phoneHieght(context)*0.30,
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
  Widget ellipticalWidget(String name, String type, String gifPath, String duration) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: null, // You can replace this with your custom function
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // GIF Section
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    bottomLeft: Radius.circular(12.0),
                  ),
                  image: DecorationImage(
                    image: AssetImage(gifPath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Name
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Duration
                      Text(
                        'Duration: $duration',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Blue accent line
              Container(
                width: 4,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
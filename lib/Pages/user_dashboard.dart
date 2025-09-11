import 'package:flutter/material.dart';
import 'package:rkfitness/Pages/bmiPage.dart';
import 'package:rkfitness/Pages/homePage.dart';
import 'package:rkfitness/Pages/schedualPage.dart';
import 'package:rkfitness/Pages/workoutPage.dart';

class UserDashBoard extends StatefulWidget {
  State<UserDashBoard> createState() {
    return _UserDashBoard();
  }
}

class _UserDashBoard extends State<UserDashBoard> {

  int pageNo=0;
  List<Widget> PageList = [
    HomePage(),
    WorkoutPage(),
    SchedualPage(),
    BmiPage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Center(
          child: PageList[pageNo]
       ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: true,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: pageNo,
          onTap: (index){
            setState(() {
              pageNo = index;
            });
          },
          backgroundColor: Colors.red[900],
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.fitness_center_sharp),label: "Workout"),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_sharp),label: "Schedual"),
              BottomNavigationBarItem(icon: Icon(Icons.calculate_sharp),label: "Bmi")
      ],


        ),
    );

  }

}

import 'package:flutter/material.dart';
import 'package:rkfitness/AdminMaster/AdminworkoutPage.dart';
import 'package:rkfitness/AdminMaster/addminhomePage.dart';
import 'package:rkfitness/AdminMaster/totalUser.dart';
import 'package:rkfitness/Pages/bmiPage.dart';
import 'package:rkfitness/Pages/homePage.dart';
import 'package:rkfitness/Pages/schedualPage.dart';
import 'package:rkfitness/Pages/workoutPage.dart';

import 'adminCalender.dart';

class AdminDashboard extends StatefulWidget {
  State<AdminDashboard> createState() {
    return _AdminDashboard();
  }
}

class _AdminDashboard extends State<AdminDashboard> {

  int pageNo=0;
  List<Widget> PageList = [
   AdminHome(),
    AdminWorkoutPage(),
    CalendarPage(),
    UsersPage()
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
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_sharp),label: "Calender"),
              BottomNavigationBarItem(icon: Icon(Icons.person),label: "Users")
      ],


        ),
    );

  }

}

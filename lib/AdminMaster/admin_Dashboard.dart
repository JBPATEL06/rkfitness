import 'package:flutter/material.dart';
import 'package:rkfitness/AdminMaster/admin_workout_page.dart';
import 'package:rkfitness/AdminMaster/admin_home_page.dart';
import 'package:rkfitness/AdminMaster/total_user.dart';
import 'package:rkfitness/AdminMaster/admin_calendar.dart';
import 'package:rkfitness/utils/responsive.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() {
    return _AdminDashboard();
  }
}

class _AdminDashboard extends State<AdminDashboard> {

  int pageNo=0;
  List<Widget> PageList = [
   const AdminHome(),
   const AdminWorkoutPage(),
   const CalendarPage(),
   const UsersPage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Center(
          child: PageList[pageNo]
       ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageNo,
          onTap: (index){
            setState(() {
              pageNo = index;
            });
          },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: Responsive.getProportionateScreenWidth(context, 24)),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_sharp, size: Responsive.getProportionateScreenWidth(context, 24)),
                label: "Workout",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_sharp, size: Responsive.getProportionateScreenWidth(context, 24)),
                label: "Calender",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: Responsive.getProportionateScreenWidth(context, 24)),
                label: "Users",
              ),
      ],


        ),
    );

  }

}
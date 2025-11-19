import 'package:flutter/material.dart';
import 'package:rkfitness/AdminMaster/admin_workout_page.dart';
import 'package:rkfitness/AdminMaster/admin_home_page.dart';
import 'package:rkfitness/AdminMaster/total_user.dart';
import 'package:rkfitness/AdminMaster/admin_calendar.dart';
// REMOVED: import 'package:rkfitness/utils/responsive.dart';
// ADDED import for screenutil extensions (.w, .h, .sp, .r)
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                // CONVERTED icon size to responsive width
                icon: Icon(Icons.home, size: 24.w), 
                label: "Home",
              ),
              BottomNavigationBarItem(
                 // CONVERTED icon size to responsive width
                icon: Icon(Icons.fitness_center_sharp, size: 24.w),
                label: "Workout",
              ),
              BottomNavigationBarItem(
                 // CONVERTED icon size to responsive width
                icon: Icon(Icons.calendar_month_sharp, size: 24.w),
                label: "Calender",
              ),
              BottomNavigationBarItem(
                 // CONVERTED icon size to responsive width
                icon: Icon(Icons.person, size: 24.w),
                label: "Users",
              ),
      ],


        ),
    );

  }

}
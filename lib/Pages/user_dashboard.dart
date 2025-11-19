import 'package:flutter/material.dart';
import 'package:rkfitness/Pages/bmiPage.dart';
import 'package:rkfitness/Pages/homePage.dart';
import 'package:rkfitness/Pages/schedualPage.dart';
import 'package:rkfitness/Pages/workoutPage.dart';
// REMOVED: import 'package:rkfitness/utils/responsive.dart';
// ADDED import for screenutil extensions (.w, .h, .sp, .r)
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDashBoard extends StatefulWidget {
  const UserDashBoard({super.key});
  @override
  State<UserDashBoard> createState() {
    return _UserDashBoard();
  }
}

class _UserDashBoard extends State<UserDashBoard> {
  int pageNo = 0;
  final userEmail = Supabase.instance.client.auth.currentUser?.email ?? '';

  late final List<Widget> PageList = [
    const HomePage(),
    const WorkoutPage(),
    SchedualPage(userEmail: userEmail),
    const BmiPage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PageList[pageNo],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageNo,
        onTap: (index) {
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
            label: "Schedual",
          ),
          BottomNavigationBarItem(
            // CONVERTED icon size to responsive width
            icon: Icon(Icons.calculate_sharp, size: 24.w),
            label: "Bmi",
          ),
        ],
      ),
    );
  }
}
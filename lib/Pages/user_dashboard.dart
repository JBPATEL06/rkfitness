import 'package:flutter/material.dart';
import 'package:rkfitness/Pages/bmiPage.dart';
import 'package:rkfitness/Pages/homePage.dart';
import 'package:rkfitness/Pages/schedualPage.dart';
import 'package:rkfitness/Pages/workoutPage.dart';
import 'package:rkfitness/utils/responsive.dart';
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
            icon: Icon(Icons.home, size: Responsive.getProportionateScreenWidth(context, 24)),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_sharp, size: Responsive.getProportionateScreenWidth(context, 24)),
            label: "Workout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_sharp, size: Responsive.getProportionateScreenWidth(context, 24)),
            label: "Schedual",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_sharp, size: Responsive.getProportionateScreenWidth(context, 24)),
            label: "Bmi",
          ),
        ],
      ),
    );
  }
}
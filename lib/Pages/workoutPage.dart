import 'package:flutter/cupertino.dart';
import 'package:rkfitness/customeWidAndFun.dart';

class WorkoutPage extends StatefulWidget {
  @override
  State<WorkoutPage> createState() => _WorkoutPage();

}
class _WorkoutPage extends State<WorkoutPage>{
  CustomeWidAndFun mywidget = CustomeWidAndFun();
  Widget build(BuildContext context){

    return mywidget.scheduallist(context, "Name", "Exercise","https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/", "Duration");
  }
}
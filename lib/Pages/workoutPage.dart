import 'package:flutter/cupertino.dart';
import 'package:rkfitness/customeWidAndFun.dart';

class WorkoutPage extends StatefulWidget {
  @override
  State<WorkoutPage> createState() => _WorkoutPage();

}
class _WorkoutPage extends State<WorkoutPage>{
  CustomeWidAndFun mywidget = CustomeWidAndFun();
  Widget build(BuildContext context){

    return mywidget.scheduallist(context, "Name", "Exercise","https://tenor.com/view/supino-gif-1051970891886466370", "Duration");
  }
}
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rkfitness/customWidgets/weekdays.dart';
import 'package:rkfitness/customeWidAndFun.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePage();

}
class _HomePage extends State<HomePage>{

  Set<Days> _selectedDay = {};
  CustomeWidAndFun mywidget = new CustomeWidAndFun();
  String tempImageUrl = "https://tenor.com/view/supino-gif-1051970891886466370";
  void initState() {
    super.initState();
    _selectedDay = {mywidget.getCurrentDay()};
  }
  Widget build(BuildContext context){
    return Scaffold(
    appBar: PreferredSize(preferredSize: Size.fromHeight(100) ,
        child: rkuAppBar(context)),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 5),
              Text("Scheduel's Days",style: TextStyle(fontSize: 20),),
              SizedBox(height: 5,),
              Weekdays(
                selectedDay: _selectedDay,
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[ Text.rich(
                    mywidget.redText("Cardio")
                  ),
                    TextButton(onPressed: null, child: Text("see all",style: TextStyle(
                      fontSize: 16,
                      color: Colors.black
                    ),))
                  ],
                ),
              ),
              SizedBox(
                height: 250,
                child: Expanded(

                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                      itemBuilder: (context,index)
                  {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: mywidget.workout(tempImageUrl, "exerciseName"),
                    );
                  }
                  ),
                ),
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Text.rich(
                      mywidget.redText("Exercise")
                  ),
                    TextButton(onPressed: null, child: Text("see all",style: TextStyle(
                        fontSize: 16,
                        color: Colors.black
                    ),))
                  ],
                ),
              ),
            SizedBox(
              height: 250,
              child: Expanded(

                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context,index)
                    {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: mywidget.workout(tempImageUrl, "exerciseName"),
                      );
                    }
                ),
              ),
            )
            ],
          ),
        )
    );
  }
  //App bar Created by  Jeel
  Widget rkuAppBar(BuildContext context) {
    String _ProfilePic =
        "https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE";

    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.red[800],
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.0,
              backgroundColor: Colors.grey,
              child: ClipOval(
                child: Image.network(
                  _ProfilePic,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Icon(Icons.person);
                  },
                ),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Welcome ,",
                    style: TextStyle(
                        fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400)),
                Text("_UserName",
                    style: TextStyle(
                        fontSize: 18, color: Colors.white, fontWeight: FontWeight.w400)),
              ],
            ),
            Spacer(), // pushes icon to right
            Icon(Icons.notifications, color: Colors.white),
          ],
        ),
      ),
    );
  }

// mywidget.workout(tempImageUrl,"Jeel"),
}
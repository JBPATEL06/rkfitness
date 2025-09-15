import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePage();

}
class _HomePage extends State<HomePage>{
  String tempImageUrl = "https://tenor.com/view/supino-gif-1051970891886466370";
  Widget build(BuildContext context){
    return Scaffold(
    appBar: PreferredSize(preferredSize: Size.fromHeight(100) , child: rkuAppBar(context)),
        body: workout(tempImageUrl,"Jeel"),
    );
  }
  //App bar Created by  Jeel
  Widget rkuAppBar(BuildContext context){
    String _ProfilePic = "https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE";
    return Container(
      color: Colors.red[800],
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
                  loadingBuilder: (context,child, loadingProgress)
                  {
                    if(loadingProgress == null) return child;
                    return Icon(Icons.person);
                  }

              ),
            ),
          ),
          SizedBox(width:20,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome ,",style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),),
              Text("_UserName",style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),)
            ],
          ),
          SizedBox(width: 200,),

          Icon(Icons.notifications)

        ],
      ),
    );
  }
  //Widget created by Dhruvil
  Widget workout(String imagePath, String exerciseName) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        height: 250,
        width: 200,
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

}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rkfitness/AdminMaster/admin_edit_workout.dart';
import 'package:rkfitness/Pages/fullWorkout.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/utils/responsive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../customWidgets/weekdays.dart';

class CustomeWidAndFun {
  Widget workout12(BuildContext context, WorkoutTableModel workout) {
    final theme = Theme.of(context);
    final gifUrl = workout.gifPath != null
        ? Supabase.instance.client.storage
        .from('image_and_gifs')
        .getPublicUrl(workout.gifPath!)
        : 'https://via.placeholder.com/150';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FullWorkoutPage(
                workout: workout,
              )),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.getProportionateScreenWidth(context, 16)),
        child: Container(
          height: Responsive.responsiveHeight(context, 40),
          width: Responsive.responsiveWidth(context, 45),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            image: DecorationImage(
              image: NetworkImage(gifUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
              color: Colors.black.withAlpha(128), // 0.5 * 255 = 128
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(Responsive.getProportionateScreenWidth(context, 16)),
                    bottomRight: Radius.circular(Responsive.getProportionateScreenWidth(context, 16)),
                  ),
                ),
                padding: EdgeInsets.all(Responsive.getProportionateScreenWidth(context, 8)),
                child: Text(
                  workout.workoutName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.getProportionateScreenWidth(context, 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan redText(String text) {
    if (text.isEmpty) {
      return const TextSpan(text: '');
    }
    return TextSpan(
      children: [
        TextSpan(
          text: text[0],
          style: const TextStyle(
            color: Colors.red,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: text.substring(1),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Days getCurrentDay() {
    int weekday = DateTime.now().weekday;
    // Assuming Days is an enum where Days.values[0] is Monday (ISO 8601 standard)
    return Days.values[weekday - 1];
  }

  String stringgetCurrentDay() {
    DateTime now = DateTime.now();
    return DateFormat('EEE')
        .format(now)
        .toUpperCase();
  }

  Widget workout(BuildContext context, WorkoutTableModel workout) {
    final theme = Theme.of(context);
    final gifUrl = workout.gifPath != null
        ? Supabase.instance.client.storage
        .from('image_and_gifs')
        .getPublicUrl(workout.gifPath!)
        : 'https://via.placeholder.com/150';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FullWorkoutPage(
                workout: workout,
              )),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.getProportionateScreenWidth(context, 16)),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                vertical: Responsive.getProportionateScreenHeight(context, 0),
                horizontal: Responsive.getProportionateScreenWidth(context, 8),
              ),
              height: Responsive.responsiveHeight(context, 30),
              width: Responsive.responsiveWidth(context, 45),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Responsive.getProportionateScreenWidth(context, 16)),
                color: theme.colorScheme.surface,
                image: DecorationImage(
                  image: NetworkImage(gifUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                 color: Colors.black.withAlpha(128), // 0.5 * 255 = 128
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(Responsive.getProportionateScreenWidth(context, 16)),
                        bottomRight: Radius.circular(Responsive.getProportionateScreenWidth(context, 16)),
                      ),
                    ),
                    padding: EdgeInsets.all(Responsive.getProportionateScreenWidth(context, 8)),
                    child: Text(
                      workout.workoutName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.getProportionateScreenWidth(context, 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: Responsive.getProportionateScreenHeight(context, 8),
              right: Responsive.getProportionateScreenWidth(context, 8),
              child: IconButton(
                icon: Icon(Icons.edit, color: theme.colorScheme.primary, size: Responsive.getProportionateScreenWidth(context, 24)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditWorkoutPage(
                          workoutToEdit:
                          workout,
                        )),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
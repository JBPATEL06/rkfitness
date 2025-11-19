import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ADDED
import 'package:rkfitness/AdminMaster/admin_edit_workout.dart';
import 'package:rkfitness/Pages/fullWorkout.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../customWidgets/weekdays.dart';

class CustomeWidAndFun {

  // FIX: Helper function to safely get the image URL
  String _getSafeGifUrl(String? gifPath) {
      if (gifPath != null && gifPath.isNotEmpty) {
          try {
              return Supabase.instance.client.storage
                  .from('image_and_gifs')
                  .getPublicUrl(gifPath);
          } catch (e) {
              return 'https://via.placeholder.com/150';
          }
      }
      return 'https://via.placeholder.com/150';
  }

  // NOTE: This widget seems unused in your current app logic, but it's converted for consistency.
  Widget workout12(BuildContext context, WorkoutTableModel workout) {
    final theme = Theme.of(context);
    final gifUrl = _getSafeGifUrl(workout.gifPath);

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
        borderRadius: BorderRadius.circular(16.r), // CONVERTED
        child: Container(
          // CONVERTED to use fixed sizes relative to the design size (360x690)
          height: 200.h, 
          width: 160.w, 
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
                    bottomLeft: Radius.circular(16.r), // CONVERTED
                    bottomRight: Radius.circular(16.r), // CONVERTED
                  ),
                ),
                padding: EdgeInsets.all(8.w), // CONVERTED
                child: Text(
                  workout.workoutName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp, // CONVERTED
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
          style: TextStyle( // CONVERTED
            color: Colors.red,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: text.substring(1),
          style: TextStyle( // CONVERTED
            color: Colors.black,
            fontSize: 24.sp,
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
    final gifUrl = _getSafeGifUrl(workout.gifPath);

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
        borderRadius: BorderRadius.circular(16.r), // CONVERTED
        child: Stack(
          children: [
            Container(
              // Using W for consistent proportional margin, assuming 8px design margin
              margin: EdgeInsets.symmetric(
                vertical: 0.h, 
                horizontal: 8.w, // CONVERTED
              ),
              // Setting fixed dimensions relative to the design size
              height: 200.h, // Approx 30% of 690h is 207h, using a hardcoded responsive height
              width: 160.w, // Approx 45% of 360w is 162w, using a hardcoded responsive width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r), // CONVERTED
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
                        bottomLeft: Radius.circular(16.r), // CONVERTED
                        bottomRight: Radius.circular(16.r), // CONVERTED
                      ),
                    ),
                    padding: EdgeInsets.all(8.w), // CONVERTED
                    child: Text(
                      workout.workoutName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp, // CONVERTED
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8.h, // CONVERTED
              right: 8.w, // CONVERTED
              child: IconButton(
                icon: Icon(Icons.edit, color: theme.colorScheme.primary, size: 24.w), // CONVERTED
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
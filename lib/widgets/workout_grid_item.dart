import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ADDED
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/Pages/fullWorkout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutGridItem extends StatelessWidget {
  const WorkoutGridItem({super.key, required this.workout});

  final WorkoutTableModel workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String? gifUrl;
    // FIX: Only attempt to get URL if path is not null AND not empty
    if (workout.gifPath != null && workout.gifPath!.isNotEmpty) {
      try {
        gifUrl = Supabase.instance.client.storage
            .from('image_and_gifs')
            .getPublicUrl(workout.gifPath!);
      } catch (e) {
        // If generating the URL fails for any reason, treat it as missing
        gifUrl = null; 
      }
    }

    final bool useNetworkImage = gifUrl != null && gifUrl.isNotEmpty;

    // Use a local widget for the image area based on URL validity
    Widget imageWidget = useNetworkImage
        ? FadeInImage.assetNetwork(
            placeholder: 'assets/images/Rku_Logo.png', // placeholder asset
            image: gifUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            // Error builder for network image failures
            imageErrorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 32.w, // CONVERTED
                    ),
                    SizedBox(height: 8.h), // CONVERTED
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 12.sp, // CONVERTED
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          )
        // Fallback to a local icon when no valid URL is present
        : Center(
            child: Icon(
              Icons.image_not_supported,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              size: 50.w, // CONVERTED
            ),
          );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullWorkoutPage(
              workout: workout,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r), // CONVERTED
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageWidget, // Use the fully safe image widget
              Container(
                alignment: Alignment.bottomCenter,
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
}
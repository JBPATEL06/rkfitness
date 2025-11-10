import 'package:flutter/material.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/Pages/fullWorkout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutGridItem extends StatelessWidget {
  const WorkoutGridItem({super.key, required this.workout});

  final WorkoutTableModel workout;

  @override
  Widget build(BuildContext context) {
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
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FadeInImage.assetNetwork(
                placeholder: 'assets/images/loading.gif', // placeholder asset
                image: gifUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
              Container(
                alignment: Alignment.bottomCenter,
                width: double.infinity,
                decoration: BoxDecoration(
              color: Colors.black.withAlpha(128), // 0.5 * 255 = 128
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  workout.workoutName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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

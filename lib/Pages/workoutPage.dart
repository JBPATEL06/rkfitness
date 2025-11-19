import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ADDED
import 'package:provider/provider.dart';
import 'package:rkfitness/providers/workout_provider.dart';
import 'package:rkfitness/widgets/workout_grid_item.dart';
import 'package:rkfitness/widgets/loading_overlay.dart';
import 'package:rkfitness/widgets/error_message.dart';
import 'package:rkfitness/widgets/connection_status.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  String _selectedTab = 'Cardio';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkoutProvider>(context, listen: false)
          .fetchWorkoutsByCategory(_selectedTab.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workoutProvider = context.watch<WorkoutProvider>();
    
    return Scaffold(
        appBar: AppBar(
          title: const Text('WORKOUT'),
        ),
        body: Column(
        children: [
          const ConnectionStatus(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: theme.colorScheme.primary,
              ),
              child: Row(
                children: [
                  _buildTabItem('Cardio'),
                  _buildTabItem('Exercise'),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<WorkoutProvider>(
              builder: (context, provider, child) {
                if (provider.error != null) {
                  return ErrorMessage(
                    message: 'Error loading workouts',
                    onRetry: () => provider.fetchWorkoutsByCategory(_selectedTab.toLowerCase()),
                  );
                }

                final workouts = provider.workouts[_selectedTab.toLowerCase()] ?? [];

                if (workouts.isEmpty && !provider.isLoading) {
                  return Center(
                    child: Text(
                      'No workouts found in this category.',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive column count based on screen width
                    int crossAxisCount;
                    if (constraints.maxWidth > 1200) {
                      crossAxisCount = 4;
                    } else if (constraints.maxWidth > 800) {
                      crossAxisCount = 3;
                    } else {
                      crossAxisCount = 2;
                    }
                    return LoadingOverlay(
                      isLoading: provider.isLoading,
                      message: 'Loading workouts...',
                      child: GridView.builder(
                        padding: EdgeInsets.all(16.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          // AspectRatio of 0.6 ensures the card height scales proportionally to the width.
                          childAspectRatio: 0.6,
                        ),
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          final workout = workouts[index];
                          return WorkoutGridItem(workout: workout);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title) {
    final theme = Theme.of(context);
    final isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = title;
            Provider.of<WorkoutProvider>(context, listen: false)
                .fetchWorkoutsByCategory(_selectedTab.toLowerCase());
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
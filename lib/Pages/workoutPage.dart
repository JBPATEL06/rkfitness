import 'package:flutter/material.dart';
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
          ConnectionStatus(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
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
                  return const Center(
                    child: Text(
                      'No workouts found in this category.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
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
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
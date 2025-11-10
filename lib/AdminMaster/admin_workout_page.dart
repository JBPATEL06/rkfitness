import 'package:flutter/material.dart';
import 'package:rkfitness/widgets/custom_widgets.dart'; // Assuming this imports CustomeWidAndFun
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/utils/responsive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_add_workout.dart';

class AdminWorkoutPage extends StatefulWidget {
  const AdminWorkoutPage({super.key});

  @override
  State<AdminWorkoutPage> createState() => _AdminWorkoutPageState();
}

class _AdminWorkoutPageState extends State<AdminWorkoutPage> {
  String _selectedTab = 'Cardio';

  Future<List<WorkoutTableModel>> _fetchWorkouts(String category) async {
    try {
      final response = await Supabase.instance.client
          .from('Workout Table')
          .select()
          .eq('Workout type', category);

      return (response as List)
          .map((workout) => WorkoutTableModel.fromJson(workout))
          .toList();
    } catch (e) {
      print('Error fetching workouts: $e');
      return [];
    }
  }

  Widget _buildWorkoutGrid(BuildContext context, String category) {
    return FutureBuilder<List<WorkoutTableModel>>(
      future: _fetchWorkouts(category.toLowerCase()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No $category workouts found.'));
        }
        final workouts = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: Responsive.responsiveHeight(context, 35),
          ),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workoutData = workouts[index];
            return CustomeWidAndFun().workout(context, workoutData);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('WORKOUT'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.colorScheme.primary),
              child: Row(
                children: [
                  _buildTabItem('Cardio'),
                  _buildTabItem('Exercise'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _buildWorkoutGrid(context, _selectedTab),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWorkoutPage()),
          ).then((_) {
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
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
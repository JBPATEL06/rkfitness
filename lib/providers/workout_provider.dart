import 'package:flutter/material.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WorkoutProvider with ChangeNotifier {
  Map<String, List<WorkoutTableModel>> _workouts = {};
  bool _isLoading = false;
  String? _error;

  Map<String, List<WorkoutTableModel>> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWorkoutsByCategory(String category, {bool forceRefresh = false}) async {
    if (_workouts.containsKey(category) && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection available');
      }

      final response = await Supabase.instance.client
          .from('Workout Table')
          .select()
          .eq('Workout type', category);

      _workouts[category] = (response as List)
          .map((data) => WorkoutTableModel.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearWorkouts() {
    _workouts.clear();
    _error = null;
    notifyListeners();
  }
}
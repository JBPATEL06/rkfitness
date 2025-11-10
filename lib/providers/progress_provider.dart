import 'package:flutter/foundation.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/supabaseMaster/user_progress_services.dart';

class ProgressProvider with ChangeNotifier {
  final UserProgressService _progressService = UserProgressService();
  String? _error;
  bool _isLoading = false;

  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> logWorkoutCompletion({
    required String userEmail,
    required WorkoutTableModel workout,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _progressService.logWorkoutCompletion(
        userEmail: userEmail,
        workout: workout,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getUserProgress(String userEmail) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final progressList = await _progressService.getUserProgress(userEmail);
      _isLoading = false;
      notifyListeners();
      return progressList.map((progress) => {
        'day': progress.day,
        'time': progress.time?.toIso8601String(),
        'completedExerciseCount': progress.completedExerciseCount,
        'completedCardioCount': progress.completedCardioCount,
      }).toList();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
}
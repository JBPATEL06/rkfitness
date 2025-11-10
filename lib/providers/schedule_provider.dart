import 'package:flutter/foundation.dart';
import 'package:rkfitness/supabaseMaster/schedual_services.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleWorkoutService _scheduleService = ScheduleWorkoutService();
  String? _error;
  bool _isLoading = false;

  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>?> getCustomWorkoutDetailsForToday(String userEmail, String workoutId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final details = await _scheduleService.getCustomWorkoutDetailsForToday(userEmail, workoutId);
      _isLoading = false;
      notifyListeners();
      if (details == null) return null;
      return {
        'customDuration': details.customDuration,
        'dayOfWeek': details.dayOfWeek,
        'scheduleId': details.id,
      };
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getScheduledWorkoutsForUser(String userEmail) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final schedules = await _scheduleService.getScheduledWorkoutsForUser(userEmail);
      _isLoading = false;
      notifyListeners();
      return schedules.map((schedule) => {
        'workoutId': schedule.workoutId,
        'dayOfWeek': schedule.dayOfWeek,
        'customDuration': schedule.customDuration,
        'scheduleId': schedule.id,
      }).toList();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
}
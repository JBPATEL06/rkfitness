import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/supabaseMaster/schedual_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final ScheduleWorkoutService _scheduleService = ScheduleWorkoutService();
  late Future<Map<String, List<WorkoutTableModel>>> _workoutsFuture;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<String, List<WorkoutTableModel>> _workoutsByDayOfWeek = {};

  @override
  void initState() {
    super.initState();
    _workoutsFuture = _fetchAndProcessWorkouts();
  }

  Future<Map<String, List<WorkoutTableModel>>> _fetchAndProcessWorkouts() async {
    final userEmail = Supabase.instance.client.auth.currentUser?.email;
    if (userEmail == null) {
      return {};
    }

    final scheduledWorkouts =
    await _scheduleService.getScheduledWorkoutsForUserWithDetails(userEmail);

    Map<String, List<WorkoutTableModel>> workoutsMap = {};

    for (var schedule in scheduledWorkouts) {
      final day = schedule['day_of_week'] as String;
      final workoutData = schedule['Workout Table'];
      if (workoutData != null) {
        final workout = WorkoutTableModel.fromJson(workoutData);
        if (workoutsMap.containsKey(day)) {
          workoutsMap[day]!.add(workout);
        } else {
          workoutsMap[day] = [workout];
        }
      }
    }
    _workoutsByDayOfWeek = workoutsMap;
    return workoutsMap;
  }

  List<WorkoutTableModel> _getWorkoutsForDay(DateTime day) {
    // Converts DateTime's weekday (1 for Mon, 7 for Sun) to a string key ('MON', 'SUN')
    final String dayKey =
    DateFormat('EEE').format(day).toUpperCase();
    return _workoutsByDayOfWeek[dayKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, List<WorkoutTableModel>>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading schedule.'));
          }

          final workoutsForSelectedDay = _getWorkoutsForDay(_selectedDay);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                eventLoader: _getWorkoutsForDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.grey[700]),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left),
                  rightChevronIcon: Icon(Icons.chevron_right),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Workouts for ${DateFormat.yMMMd().format(_selectedDay)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: workoutsForSelectedDay.isEmpty
                    ? const Center(
                    child: Text('No workouts scheduled for this day.'))
                    : ListView.builder(
                  itemCount: workoutsForSelectedDay.length,
                  itemBuilder: (context, index) {
                    final workout = workoutsForSelectedDay[index];
                    return ListTile(
                      leading: const Icon(Icons.fitness_center, color: Colors.red),
                      title: Text(workout.workoutName),
                      subtitle: Text(workout.workoutType ?? ''),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
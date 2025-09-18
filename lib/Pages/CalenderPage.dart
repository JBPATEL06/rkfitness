import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Dummy data for scheduled workouts. This would come from a database.
  final Map<DateTime, List<dynamic>> _workouts = {
    // September 8, 2025 has a workout
    DateTime(2025, 9, 8): [
      {'name': 'Treadmill Running', 'icon': Icons.directions_run},
    ],
    // Add other dummy workouts here
    DateTime(2025, 9, 10): [
      {'name': 'Weight Lifting', 'icon': Icons.fitness_center},
      {'name': 'Cycling', 'icon': Icons.pedal_bike},
    ],
  };

  // Helper function to get workouts for a given day
  List<dynamic> _getWorkoutsForDay(DateTime day) {
    // The key in the map needs to be a simplified date (without time)
    final key = DateTime(day.year, day.month, day.day);
    return _workouts[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Today, 1st Sep', // This should be dynamic
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          // List of exercises for the selected day
          Expanded(
            child: ListView.builder(
              itemCount: _getWorkoutsForDay(_selectedDay).length,
              itemBuilder: (context, index) {
                final workout = _getWorkoutsForDay(_selectedDay)[index];
                return ListTile(
                  leading: Icon(workout['icon']),
                  title: Text(workout['name']),
                  // Add more workout details here
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
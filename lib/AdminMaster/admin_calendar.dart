import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/supabaseMaster/user_progress_services.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final UserProgressService _progressService = UserProgressService();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<UserModel> _activeUsersForSelectedDay = [];
  bool _isLoading = false;
  // State to track which days have had activity found by the admin
  final Set<DateTime> _activeDaysWithEntry = {}; 

  @override
  void initState() {
    super.initState();
    _fetchUsersForDay(_selectedDay);
  }

  // Function to determine if a day should have a marker
  List<UserModel> _getEventsForDay(DateTime day) {
    // We only mark the day if we have previously fetched users for it and found entries
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _activeDaysWithEntry.contains(normalizedDay) ? [UserModel(gmail: '')] : [];
  }

  Future<void> _fetchUsersForDay(DateTime day) async {
    setState(() => _isLoading = true);
    final users = await _progressService.getActiveUsersForDay(day);
    if (mounted) {
      setState(() {
        _activeUsersForSelectedDay = users;
        _isLoading = false;
        // Mark the day if activity was found
        final normalizedDay = DateTime(day.year, day.month, day.day);
        if (users.isNotEmpty) {
          _activeDaysWithEntry.add(normalizedDay);
        } else {
          _activeDaysWithEntry.remove(normalizedDay);
        }
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _fetchUsersForDay(selectedDay);
    }
  }

  Future<void> _showUserDetailsDialog(UserModel user) async {
    final theme = Theme.of(context);
    final progress = await _progressService.getProgressForDay(user.gmail, _selectedDay);

    if (progress == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load progress details.')),
        );
      }
      return;
    }

    final totalExercises = progress.completedExerciseCount ?? 0;
    final totalCardio = progress.completedCardioCount ?? 0;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user.name ?? user.gmail.split('@').first, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Email: ${user.gmail}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                const Divider(height: 20),
                _buildStatRow('Exercises:', totalExercises.toString()),
                _buildStatRow('Cardio Sessions:', totalCardio.toString()),

                if (totalExercises == 0 && totalCardio == 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text('No workouts logged on this day.'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: theme.colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay, // Use the new event loader
            calendarStyle: CalendarStyle(
              // TODAY: Light red circle
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(77),
                shape: BoxShape.circle,
              ),
              // SELECTED: Full red circle
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              // MARKER: Small black dot
              markerDecoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1, // Only show one marker/dot
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Active on ${DateFormat.yMMMd().format(_selectedDay)}',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _activeUsersForSelectedDay.isEmpty
                ? const Center(child: Text('No users were active on this day.'))
                : ListView.builder(
              itemCount: _activeUsersForSelectedDay.length,
              itemBuilder: (context, index) {
                final user = _activeUsersForSelectedDay[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: user.profilePicture != null
                        ? NetworkImage(user.profilePicture!)
                        : null,
                    child: user.profilePicture == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(user.name ?? 'N/A'),
                  subtitle: Text(user.gmail),
                  onTap: () => _showUserDetailsDialog(user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        ],
      ),
    );
  }
}
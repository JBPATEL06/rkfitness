import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rkfitness/models/user_progress_model.dart';
import 'package:rkfitness/supabaseMaster/user_progress_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final UserProgressService _progressService = UserProgressService();
  late Future<List<UserProgressModel>> _progressFuture;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<UserProgressModel> _allProgress = [];

  @override
  void initState() {
    super.initState();
    _progressFuture = _fetchUserProgress();
  }

  Future<List<UserProgressModel>> _fetchUserProgress() async {
    final userEmail = Supabase.instance.client.auth.currentUser?.email;
    if (userEmail == null) return [];

    final progressList = await _progressService.getUserProgress(userEmail);
    if (mounted) {
      setState(() {
        _allProgress = progressList;
      });
    }
    return progressList;
  }

  UserProgressModel? _getProgressForDay(DateTime day) {
    try {
      return _allProgress.firstWhere((p) =>
      p.time != null && isSameDay(p.time!, day)
      );
    } catch (e) {
      return null;
    }
  }

  List<UserProgressModel> _getEventsForDay(DateTime day) {
    // This is correctly set up to use the marker
    final progress = _allProgress.where((p) => p.time != null && isSameDay(p.time!, day)).toList();
    
    // Only return an event if there is actual activity recorded (gt 0)
    final progressEntry = progress.isNotEmpty ? progress.first : null;
    if (progressEntry != null && 
        ((progressEntry.completedExerciseCount ?? 0) > 0 || 
         (progressEntry.completedCardioCount ?? 0) > 0)) {
        return progress;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Calendar'),
      ),
      body: FutureBuilder<List<UserProgressModel>>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading progress: ${snapshot.error}'));
          }

          final progressForSelectedDay = _getProgressForDay(_selectedDay);

          return Column(
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
                eventLoader: _getEventsForDay,
                calendarStyle: CalendarStyle(
                  // TODAY: Light red circle 
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(77),
                    shape: BoxShape.circle,
                  ),
                  // SELECTED: Full red circle 
                  selectedDecoration: BoxDecoration(
                      color: theme.colorScheme.primary, 
                      shape: BoxShape.circle
                  ),
                  // TODAY TEXT: Use default black text as the background provides the color
                  todayTextStyle: TextStyle(color: theme.colorScheme.onSurface),
                  
                  // MARKER: Small black dot 
                  markerDecoration: const BoxDecoration(
                      color: Colors.black, 
                      shape: BoxShape.circle
                  ),
                  markersMaxCount: 1,
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
                  'Summary for ${DateFormat.yMMMd().format(_selectedDay)}',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: _buildCompletedWorkoutsList(progressForSelectedDay),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompletedWorkoutsList(UserProgressModel? progress) {
    if (progress == null) {
      return const Center(child: Text('No activity recorded for this day.'));
    }

    final exerciseCount = progress.completedExerciseCount ?? 0;
    final cardioCount = progress.completedCardioCount ?? 0;

    if (exerciseCount == 0 && cardioCount == 0) {
      return const Center(child: Text('No activity recorded for this day.'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard('Total Exercises Completed', exerciseCount, Icons.fitness_center),
            const SizedBox(height: 10),
            _buildStatCard('Total Cardio Sessions Completed', cardioCount, Icons.directions_run),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary, size: 30),
        title: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),  
        trailing: Text(
          count.toString(),
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}
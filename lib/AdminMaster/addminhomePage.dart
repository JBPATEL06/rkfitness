import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rkfitness/AdminMaster/AdminProfile.dart';
import 'package:rkfitness/AdminMaster/adminNotification.dart';
import 'package:rkfitness/Pages/Notification.dart';
import 'package:rkfitness/customeWidAndFun.dart';

class AdminHome extends StatelessWidget {
  AdminHome({super.key});
  final CustomeWidAndFun mywidget = CustomeWidAndFun();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.red[700],
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: (){    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  AdminProfilePage()),
                    );},
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome,', style: TextStyle(color: Colors.white, fontSize: 14)),
                      Text('Admin Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
              GestureDetector(onTap : (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SendNotificationPage()),
                );
              },child: const Icon(Icons.notifications, color: Colors.white, size: 30)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stat Cards Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(context, 'Total Users', 32, Icons.people),
                  _buildStatCard(context, 'Total Cardio', 20, Icons.fitness_center),
                  _buildStatCard(context, 'Total Exercise', 25, Icons.sports_gymnastics),
                ],
              ),
              const SizedBox(height: 20),
              // User Chart Section
              const Text(
                'User Stats',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildUserChart(),
              const SizedBox(height: 20),
              // Cardio and Exercise Sections
              _buildWorkoutSection(context, 'Cardio'),
              const SizedBox(height: 20),
              _buildWorkoutSection(context, 'Exercise'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, int value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('$value', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red)),
              Icon(icon, color: Colors.red),
              const SizedBox(height: 5),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserChart() {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: _buildChartSections(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegend('Good', Colors.orange),
                  _buildLegend('Average', Colors.purple),
                  _buildLegend('Worst', Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections() {
    return [
      PieChartSectionData(
        color: Colors.orange,
        value: 50,
        title: '50.0%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: 26.7,
        title: '26.7%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: 23.3,
        title: '23.3%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  Widget _buildLegend(String title, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(title),
      ],
    );
  }

  Widget _buildWorkoutSection(BuildContext context, String title) {
    // Dummy data for a specific workout section
    final List<Map<String, String>> workouts = [
      {'name': 'Elliptical Trainer', 'image': 'https://www.gifss.com/deportes/atletismo/images/atleta-26.gif'},
      {'name': 'Treadmill Running', 'image': 'https://www.gifss.com/deportes/atletismo/images/atleta-26.gif'},
      {'name': 'Stationary Cycling', 'image': 'https://www.gifss.com/deportes/atletismo/images/atleta-26.gif'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('see all', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200, // Fixed height for the horizontal list view
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workoutData = workouts[index];
              return mywidget.workout(context, workoutData['image']!, workoutData['name']!);
            },
          ),
        ),
      ],
    );
  }
}
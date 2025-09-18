import 'package:flutter/material.dart';

// Assuming you have an AdminDashboard class in this file path

// Class to represent a User
class User {
  final String name;
  final String email;
  final String imageUrl;

  User({
    required this.name,
    required this.email,
    required this.imageUrl,
  });
}

// Sample data to populate the user list
List<User> userList = [
  User(
    name: 'Aarav Pandya',
    email: 'Aaravp12@gmail.com',
    imageUrl: 'assets/images/aarav.jpg',
  ),
  User(
    name: 'Chirag Sharma',
    email: 'Chirags21@gmail.com',
    imageUrl: 'assets/images/chirag.jpg',
  ),
  User(
    name: 'Rudra Shah',
    email: 'Rudras23@gmail.com',
    imageUrl: 'assets/images/rudra.jpg',
  ),
  User(
    name: 'Shubham Vyas',
    email: 'Shubhamv220@gmail.com',
    imageUrl: 'assets/images/shubham.jpg',
  ),
];

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        
        title: const Text(
          'Users',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: userList.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        separatorBuilder: (context, index) => const Divider(color: Colors.grey),
        itemBuilder: (context, index) {
          final user = userList[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(user.imageUrl),
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(user.email),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the action for the floating button, e.g., add a new user
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),

    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final UserService _userService = UserService();
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _userService.getAllUsers();
  }

  void _refreshUserList() {
    setState(() {
      _usersFuture = _userService.getAllUsers();
    });
  }

  Future<void> _updateUserRole(UserModel user, String newRole) async {
    final updatedUser = UserModel(
      gmail: user.gmail,
      name: user.name,
      userType: newRole,
      profilePicture: user.profilePicture,
      weight: user.weight,
      height: user.height,
      age: user.age,
      gender: user.gender,
      bmi: user.bmi,
      streak: user.streak,
      workoutTime: user.workoutTime,
    );

    await _userService.updateUser(updatedUser);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${user.name ?? user.gmail}'s role has been updated to $newRole."),
          backgroundColor: Colors.green,
        ),
      );
    }
    _refreshUserList();
  }

  // --- DELETE LOGIC ---
  Future<void> _deleteUser(UserModel user) async {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to permanently delete user: ${user.name ?? user.gmail}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _userService.deleteUser(user.gmail);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${user.name ?? user.gmail} deleted successfully.')),
                  );
                }
                _refreshUserList();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  // --- EDIT LOGIC ---
  Future<void> _showEditUserDialog(UserModel user) async {
    final TextEditingController nameController = TextEditingController(text: user.name);
    final TextEditingController ageController = TextEditingController(text: user.age?.toString());
    final TextEditingController weightController = TextEditingController(text: user.weight?.toStringAsFixed(1) ?? '');
    final TextEditingController heightController = TextEditingController(text: user.height?.toStringAsFixed(1) ?? '');
    String? selectedGender = user.gender;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: Text('Edit User: ${user.name ?? user.gmail.split('@').first}', style: theme.textTheme.titleLarge),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                  TextField(controller: ageController, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
                  TextField(controller: weightController, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
                  TextField(controller: heightController, decoration: const InputDecoration(labelText: 'Height (cm)'), keyboardType: TextInputType.number),
                  SizedBox(height: 15.h),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female', 'Other']
                        .map((label) => DropdownMenuItem(child: Text(label), value: label))
                        .toList(),
                    onChanged: (value) => setState(() => selectedGender = value),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final updatedUser = UserModel(
                    gmail: user.gmail,
                    name: nameController.text.trim(),
                    age: int.tryParse(ageController.text),
                    weight: double.tryParse(weightController.text),
                    height: double.tryParse(heightController.text),
                    gender: selectedGender,
                    // Preserve existing fields
                    userType: user.userType,
                    profilePicture: user.profilePicture,
                    bmi: user.bmi,
                    streak: user.streak,
                    workoutTime: user.workoutTime,
                  );

                  await _userService.updateUser(updatedUser);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User details updated successfully.')),
                    );
                  }
                  _refreshUserList();
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final userList = snapshot.data!;
          return ListView.separated(
            itemCount: userList.length,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            separatorBuilder: (context, index) =>
            const Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              final user = userList[index];
              String currentUserRole = user.userType ?? 'user';

              return ListTile(
                leading: CircleAvatar(
                  radius: 25.r,
                  backgroundImage: user.profilePicture != null
                      ? NetworkImage(user.profilePicture!)
                      : null,
                  child: user.profilePicture == null
                      ? Icon(Icons.person, size: 25.w)
                      : null,
                ),
                title: Text(
                  user.name ?? user.gmail.split('@').first,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(user.gmail, style: theme.textTheme.bodyMedium),
                // FIX: Removed fixed width SizedBox and used Row with minimal sizing
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Role Dropdown (Made compact)
                    Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: DropdownButton<String>(
                        value: currentUserRole,
                        items: <String>['user', 'admin'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(
                                color: value == 'admin' ? theme.colorScheme.primary : theme.colorScheme.onSurface
                            ),),
                          );
                        }).toList(),
                        onChanged: (String? newRole) {
                          if (newRole != null && newRole != currentUserRole) {
                            _updateUserRole(user, newRole);
                          }
                        },
                        underline: Container(), // Removes underline
                        isDense: true, // Makes button compact
                      ),
                    ),
                    
                    // Edit Button (Constrained size)
                    IconButton(
                      icon: Icon(Icons.edit, color: theme.colorScheme.primary, size: 20.w),
                      onPressed: () => _showEditUserDialog(user),
                      tooltip: 'Edit User Details',
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(width: 30.w, height: 30.h),
                    ),

                    // Delete Button (Constrained size)
                    IconButton(
                      icon: Icon(Icons.delete, color: theme.colorScheme.error, size: 20.w),
                      onPressed: () => _deleteUser(user),
                      tooltip: 'Delete User',
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(width: 30.w, height: 30.h),
                    ),
                  ],
                ),
              );
            },
            
          );
        },
      ),
    );
  }
}
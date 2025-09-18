import 'package:flutter/material.dart';

// Assuming your AdminProfile.dart file is in the same 'lib' directory

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  // Text controllers to get user input from the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // A simple function to handle the "Update Profile" button press
  void _updateProfile() {
    // In a real application, you would add form validation and API calls here
    print('Updating profile with the following data:');
    print('Name: ${_nameController.text}');
    print('Email: ${_emailController.text}');
    print('Phone: ${_phoneController.text}');
    print('Password: ${_passwordController.text}');

    // Show a confirmation message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile update initiated!')),
    );

    // Navigate back to the previous screen (AdminProfile.dart)
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // It's a good practice to dispose of controllers to free up resources
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // A reusable helper function to build a text field with consistent styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200], // Light grey background
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // This command navigates back to the previous route on the stack
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Update Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false, // Aligns title to the left as in the image
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile image with an edit icon
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 15, color: Colors.white),
                      onPressed: () {
                        // Handle the logic for picking a new profile image
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Text fields for user details
            _buildTextField(controller: _nameController, labelText: 'Name'),
            const SizedBox(height: 20),
            _buildTextField(controller: _emailController, labelText: 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _buildTextField(controller: _phoneController, labelText: 'Phone', keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildTextField(controller: _passwordController, labelText: 'Password', obscureText: true),
            const SizedBox(height: 40),

            // Update Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Update Profile',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
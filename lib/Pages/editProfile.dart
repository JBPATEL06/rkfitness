import 'package:flutter/material.dart';
// Import your ProfilePage here so you can navigate back to it.

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  // Controllers for each text field to get user input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  // A simple function to handle the button press
  void _updateProfile() {
    // You would typically add validation and API calls here
    print('Updating profile with the following data:');
    print('Name: ${_nameController.text}');
    print('Email: ${_emailController.text}');
    print('Phone: ${_phoneController.text}');
    print('Password: ${_passwordController.text}');
    print('Weight: ${_weightController.text}');
    print('Age: ${_ageController.text}');
    print('Height: ${_heightController.text}');

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile update initiated!')),
    );

    // After a successful update, navigate back to the ProfilePage
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // It's important to dispose of controllers to free up resources
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // A helper method to build the consistent text fields
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
        fillColor: Colors.grey[200],
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
            // This pops the current route off the stack, returning to the previous screen.
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Update Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile image and edit icon
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
                        // Handle image selection logic here
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Text fields
            _buildTextField(controller: _nameController, labelText: 'Name'),
            const SizedBox(height: 20),
            _buildTextField(controller: _emailController, labelText: 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _buildTextField(controller: _phoneController, labelText: 'Phone', keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildTextField(controller: _passwordController, labelText: 'Password', obscureText: true),
            const SizedBox(height: 20),
            _buildTextField(controller: _weightController, labelText: 'Weight', keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(controller: _ageController, labelText: 'Age', keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(controller: _heightController, labelText: 'Height', keyboardType: TextInputType.number),
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
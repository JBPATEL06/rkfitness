import 'package:flutter/material.dart';
// Import your ProfilePage here so you can navigate back to it.
// Assuming ProfilePage.dart is in the same 'lib' directory.

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // You might want to add form validation here
  void _changePassword() {
    String oldPassword = _oldPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Basic validation example
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password and confirm password do not match!')),
      );
    } else if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 6 characters long!')),
      );
    } else {
      // Here you would typically send the data to a backend for actual password change
      print('Old Password: $oldPassword');
      print('New Password: $newPassword');
      print('Confirm Password: $confirmPassword');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password change request submitted!')),
      );

      // After successful change, navigate back to ProfilePage
      Navigator.pop(context); // This will pop the current route (ChangePasswordPage)
      // If you need to ensure it goes specifically to ProfilePage and clears others,
      // you might use Navigator.pushAndRemoveUntil or pushReplacement,
      // but Navigator.pop is sufficient if ProfilePage is the previous route.
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // This pops the current route off the navigation stack,
            // returning to the previous screen (which should be ProfilePage).
            Navigator.pop(context);

            // Alternatively, if you want to explicitly go to ProfilePage
            // and replace the current route, you could use:
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const ProfilePage()),
            // );
          },
        ),
        title: const Text(
          'Change password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false, // Align title to the left as in the image
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch button horizontally
          children: [
            // Old Password
            _buildPasswordField(
              controller: _oldPasswordController,
              labelText: 'Old-Password',
            ),
            const SizedBox(height: 20),

            // New Password
            _buildPasswordField(
              controller: _newPasswordController,
              labelText: 'New-Password',
            ),
            const SizedBox(height: 20),

            // Confirm Password
            _buildPasswordField(
              controller: _confirmPasswordController,
              labelText: 'Confirm-Password',
            ),
            const SizedBox(height: 40), // More space before the button

            // Change Password Button
            ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Button background color
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              child: const Text(
                'Change Password',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a consistent password text field
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextField(
      controller: controller,
      obscureText: true, // Hides input for passwords
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always, // Keeps label always visible
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // No border visible
        ),
        filled: true,
        fillColor: Colors.grey[200], // Light grey background for the input field
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final UserService _userService = UserService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  File? _pickedImage;
  String? _currentProfilePicUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userGmail = Supabase.instance.client.auth.currentUser?.email;
    if (userGmail == null) {
      setState(() => _isLoading = false);
      return;
    }

    final user = await _userService.getUser(userGmail);
    if (user != null) {
      setState(() {
        _nameController.text = user.name ?? '';
        _phoneController.text = user.phone ?? '';
        _emailController.text = user.gmail;
        _weightController.text = user.weight?.toString() ?? '';
        _ageController.text = user.age?.toString() ?? '';
        _heightController.text = user.height?.toString() ?? '';
        _currentProfilePicUrl = user.profilePicture;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // Function to open the image picker
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // Function to handle the "Update" button press
  Future<void> _updateProfile() async {
    final userEmail = Supabase.instance.client.auth.currentUser?.email;
    if (userEmail == null) return;

    String? newProfilePicUrl = _currentProfilePicUrl;

    if (_pickedImage != null) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final fileName = 'UserProfile/${user.id}.png';

      // Upload image to Supabase storage
      await Supabase.instance.client.storage
          .from('image_and_gifs')
          .upload(fileName, _pickedImage!, fileOptions: const FileOptions(upsert: true));

      newProfilePicUrl = Supabase.instance.client.storage
          .from('image_and_gifs')
          .getPublicUrl(fileName);
    }

    final updatedUser = UserModel(
      gmail: userEmail,
      name: _nameController.text.isEmpty ? null : _nameController.text,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      weight: double.tryParse(_weightController.text),
      age: int.tryParse(_ageController.text),
      height: double.tryParse(_heightController.text),
      profilePicture: newProfilePicUrl,
    );

    await _userService.updateUser(updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // A reusable helper method to build a text field with consistent styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
            Stack(
              children: [
                GestureDetector(
                  onTap: _pickImage, // Tapping the avatar opens the picker
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (_currentProfilePicUrl != null ? NetworkImage(_currentProfilePicUrl!) : null) as ImageProvider?,
                    child: _pickedImage == null && _currentProfilePicUrl == null
                        ? const Icon(Icons.person, size: 80, color: Colors.white)
                        : null,
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
                      onPressed: _pickImage, // Tapping the edit icon also opens the picker
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildTextField(controller: _nameController, labelText: 'Name'),
            const SizedBox(height: 20),
            _buildTextField(controller: _emailController, labelText: 'Email', keyboardType: TextInputType.emailAddress, enabled: false),
            const SizedBox(height: 20),
            _buildTextField(controller: _phoneController, labelText: 'Phone', keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildTextField(controller: _weightController, labelText: 'Weight', keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(controller: _ageController, labelText: 'Age', keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(controller: _heightController, labelText: 'Height', keyboardType: TextInputType.number),
            const SizedBox(height: 40),
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
                child: const Text('Update Profile', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
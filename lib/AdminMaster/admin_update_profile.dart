import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final UserService _userService = UserService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedGender;
  File? _pickedImage;
  String? _currentProfilePicUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    final adminGmail = Supabase.instance.client.auth.currentUser?.email;
    if (adminGmail == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final admin = await _userService.getUser(adminGmail);
    if (admin != null && mounted) {
      setState(() {
        _nameController.text = admin.name ?? '';
        _emailController.text = admin.gmail;
        _selectedGender = admin.gender;
        _currentProfilePicUrl = admin.profilePicture;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null && mounted) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    final adminEmail = Supabase.instance.client.auth.currentUser?.email;
    if (adminEmail == null) return;

    String? newProfilePicUrl = _currentProfilePicUrl;

    if (_pickedImage != null) {
      final fileExtension = _pickedImage!.path.split('.').last;
      final fileName = '${adminEmail.replaceAll('@', '_').replaceAll('.', '_')}.$fileExtension';
      final filePath = 'AdminProfile/$fileName';

      await Supabase.instance.client.storage
          .from('image_and_gifs')
          .upload(filePath, _pickedImage!, fileOptions: const FileOptions(upsert: true));

      newProfilePicUrl = Supabase.instance.client.storage
          .from('image_and_gifs')
          .getPublicUrl(filePath);
    }

    final updatedAdmin = UserModel(
      gmail: adminEmail,
      name: _nameController.text.trim(),
      gender: _selectedGender,
      profilePicture: newProfilePicUrl,
    );

    await _userService.updateUser(updatedAdmin);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: theme.colorScheme.onSurface.withAlpha(26),
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : (_currentProfilePicUrl != null ? NetworkImage(_currentProfilePicUrl!) : null) as ImageProvider?,
                  child: _pickedImage == null && _currentProfilePicUrl == null
                      ? Icon(Icons.person, size: 50.w, color: theme.colorScheme.onSurface)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 15.r,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(Icons.edit, size: 15.w, color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            _buildTextField(controller: _nameController, labelText: 'Name'),
            SizedBox(height: 20.h),
            _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                enabled: false),
            SizedBox(height: 20.h),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
              ),
              items: ['Male', 'Female', 'Other']
                  .map((label) => DropdownMenuItem(
                child: Text(label),
                value: label,
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateProfile,
                child:
                const Text('Update Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
      ),
    );
  }
}
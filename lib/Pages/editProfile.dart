import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:rkfitness/widgets/loading_overlay.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String? _selectedGender;
  File? _pickedImage;
  String? _currentProfilePicUrl;
  bool _isUploading = false;
  bool _isSaving = false;
  String _loadingMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<UserProvider>().currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.name ?? '';
        _emailController.text = user.gmail;
        _weightController.text = user.weight?.toString() ?? '';
        _ageController.text = user.age?.toString() ?? '';
        _heightController.text = user.height?.toString() ?? '';
        _selectedGender = user.gender;
        _currentProfilePicUrl = user.profilePicture;
      });
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
    final userProvider = context.read<UserProvider>();
    final userEmail = userProvider.currentUser?.gmail;
    if (userEmail == null) return;

    setState(() {
      _isSaving = true;
      _loadingMessage = 'Updating profile...';
    });

    try {
      String? newProfilePicUrl = _currentProfilePicUrl;

      if (_pickedImage != null) {
        setState(() {
          _loadingMessage = 'Uploading image...';
          _isUploading = true;
        });

        final fileExtension = _pickedImage!.path.split('.').last;
        final fileName = '${userEmail.replaceAll('@', '_').replaceAll('.', '_')}.$fileExtension';
        final filePath = 'UserProfile/$fileName';

        await Supabase.instance.client.storage
            .from('image_and_gifs')
            .upload(filePath, _pickedImage!, fileOptions: const FileOptions(upsert: true));

        newProfilePicUrl = Supabase.instance.client.storage
            .from('image_and_gifs')
            .getPublicUrl(filePath);

        setState(() {
          _isUploading = false;
          _loadingMessage = 'Saving profile...';
        });
      }

      final updatedUser = UserModel(
        gmail: userEmail,
        name: _nameController.text.trim(),
        weight: double.tryParse(_weightController.text),
        age: int.tryParse(_ageController.text),
        height: double.tryParse(_heightController.text),
        gender: _selectedGender,
        profilePicture: newProfilePicUrl,
      );

      await userProvider.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Profile updated successfully!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error updating profile: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _isSaving = false;
          _loadingMessage = '';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();

    return LoadingOverlay(
      isLoading: _isUploading || _isSaving || userProvider.isLoading,
      message: _loadingMessage.isNotEmpty ? _loadingMessage : 'Loading...',
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.onSurface.withAlpha(26),
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : (_currentProfilePicUrl != null ? NetworkImage(_currentProfilePicUrl!) : null) as ImageProvider?,
                  child: _pickedImage == null && _currentProfilePicUrl == null
                      ? Icon(Icons.person, size: 50, color: theme.colorScheme.onSurface)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(Icons.edit, size: 15, color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildTextField(controller: _nameController, labelText: 'Name'),
            const SizedBox(height: 20),
            _buildTextField(controller: _emailController, labelText: 'Email', enabled: false),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
              ),
              items: ['Male', 'Female', 'Other']
                  .map((label) => DropdownMenuItem(child: Text(label), value: label))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(controller: _weightController, labelText: 'Weight (kg)', keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(controller: _ageController, labelText: 'Age', keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(controller: _heightController, labelText: 'Height (cm)', keyboardType: TextInputType.number),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Update Profile'),
              ),
            ),
          ],
        ),
      ),
    ),);
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
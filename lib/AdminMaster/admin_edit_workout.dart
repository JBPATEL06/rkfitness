import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:rkfitness/supabaseMaster/workout_services.dart';

class EditWorkoutPage extends StatefulWidget {
  final WorkoutTableModel workoutToEdit;

  const EditWorkoutPage({super.key, required this.workoutToEdit});

  @override
  State<EditWorkoutPage> createState() => _EditWorkoutPageState();
}

class _EditWorkoutPageState extends State<EditWorkoutPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final WorkoutTableService _workoutService = WorkoutTableService();
  File? _pickedImage;
  String? _currentGifUrl;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.workoutToEdit.workoutName;
    _typeController.text = widget.workoutToEdit.workoutType;
    _durationController.text = widget.workoutToEdit.duration ?? '';
    _categoryController.text = widget.workoutToEdit.workoutCategory ?? '';
    _repsController.text = widget.workoutToEdit.reps?.toString() ?? '';
    _setsController.text = widget.workoutToEdit.sets?.toString() ?? '';
    _descriptionController.text = widget.workoutToEdit.description ?? '';
    _currentGifUrl = widget.workoutToEdit.gifPath;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _editWorkout() async {
    final updatedWorkout = WorkoutTableModel(
      workoutId: widget.workoutToEdit.workoutId,
      workoutName: _nameController.text,
      workoutType: _typeController.text,
      duration: _durationController.text,
      workoutCategory: _categoryController.text,
      reps: int.tryParse(_repsController.text),
      sets: int.tryParse(_setsController.text),
      description: _descriptionController.text,
      gifPath: _currentGifUrl,
    );

    await _workoutService.updateWorkout(
      workout: updatedWorkout,
      newGifFile: _pickedImage,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _durationController.dispose();
    _categoryController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Edit Workout'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundColor: theme.colorScheme.onSurface.withAlpha(26),
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (_currentGifUrl != null
                        ? NetworkImage(_currentGifUrl!)
                        : null) as ImageProvider?,
                    child: _pickedImage == null && _currentGifUrl == null
                        ? Icon(Icons.person,
                        size: 80.w,
                        color: theme.colorScheme.onPrimary)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 140.w,
                  child: CircleAvatar(
                    radius: 15.r,
                    backgroundColor: theme.colorScheme.primary,
                    child: IconButton(
                      icon: Icon(Icons.edit,
                          size: 15.w,
                          color: theme.colorScheme.onPrimary),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            _buildTextField(controller: _nameController, labelText: 'Name'),
            SizedBox(height: 20.h),
            _buildTextField(controller: _typeController, labelText: 'Type'),
            SizedBox(height: 20.h),
            _buildTextField(
                controller: _durationController,
                labelText: 'Duration'),
            SizedBox(height: 20.h),
            _buildTextField(
                controller: _categoryController, labelText: 'Category'),
            SizedBox(height: 20.h),
            _buildTextField(
                controller: _repsController,
                labelText: 'Reps',
                keyboardType: TextInputType.number),
            SizedBox(height: 20.h),
            _buildTextField(
                controller: _setsController,
                labelText: 'Sets',
                keyboardType: TextInputType.number),
            SizedBox(height: 20.h),
            _buildTextField(
                controller: _descriptionController,
                labelText: 'Description',
                maxLines: 5),
            SizedBox(height: 40.h),
            ElevatedButton(
              onPressed: _editWorkout,
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
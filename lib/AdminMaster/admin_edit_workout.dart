// File: lib/AdminMaster/admin_edit_workout.dart

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
  String? _selectedWorkoutType; 
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
    _selectedWorkoutType = widget.workoutToEdit.workoutType.toLowerCase() == 'cardio' ? 'Cardio' : 'Exercise';
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
    // FIX 1: VALIDATION FOR NON-NULLABLE FIELDS
    if (_nameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout Name cannot be empty.')),
        );
      }
      return;
    }
    if (_selectedWorkoutType == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a workout type.')),
        );
      }
      return;
    }

    String durationText = _durationController.text.trim();
    if (durationText.isNotEmpty && durationText.split(':').length == 2) {
      durationText = '00:$durationText';
    }
    
    final updatedWorkout = WorkoutTableModel(
      workoutId: widget.workoutToEdit.workoutId,
      workoutName: _nameController.text.trim(), // Use trimmed text
      workoutType: _selectedWorkoutType!.toLowerCase(),
      duration: durationText,
      workoutCategory: _categoryController.text,
      reps: int.tryParse(_repsController.text),
      sets: int.tryParse(_setsController.text),
      description: _descriptionController.text,
      gifPath: _currentGifUrl,
    );

    try {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update workout: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          icon: const Icon(Icons.close, color: Colors.white), 
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
            // GIF/Image Picker Design
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withAlpha(20),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: theme.colorScheme.primary, width: 2),
                  image: _pickedImage != null
                      ? DecorationImage(
                          image: FileImage(_pickedImage!),
                          fit: BoxFit.cover,
                        )
                      : (_currentGifUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_currentGifUrl!),
                              fit: BoxFit.cover,
                            )
                          : null),
                ),
                child: _pickedImage == null && _currentGifUrl == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 50.w, color: theme.colorScheme.primary),
                          SizedBox(height: 8.h),
                          Text('Tap to pick GIF/Image', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                        ],
                      )
                    : null,
              ),
            ),
            SizedBox(height: 30.h),
            _buildTextField(controller: _nameController, labelText: 'Name'),
            SizedBox(height: 20.h),
            DropdownButtonFormField<String>(
              value: _selectedWorkoutType,
              decoration: const InputDecoration(
                labelText: 'Workout Type',
                border: OutlineInputBorder(),
              ),
              items: <String>['Cardio', 'Exercise'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWorkoutType = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a workout type';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
            _buildTextField(
                controller: _durationController,
                labelText: 'Duration (Format: MM:SS or H:MM:SS)'),
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
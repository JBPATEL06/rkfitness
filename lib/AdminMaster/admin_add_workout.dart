import 'dart:io';
import 'package:rkfitness/models/workout_table_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rkfitness/supabaseMaster/workout_services.dart';
import 'package:uuid/uuid.dart';

class AddWorkoutPage extends StatefulWidget {
  const AddWorkoutPage({super.key});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final WorkoutTableService _workoutService = WorkoutTableService();
  File? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _addWorkout() async {
    if (_pickedImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a GIF for the workout.')),
        );
      }
      return;
    }

    final workoutId = const Uuid().v4();
    final fileExtension = _pickedImage!.path.split('.').last;
    final fileName = '$workoutId.$fileExtension';

    final newWorkout = WorkoutTableModel(
      workoutId: workoutId,
      workoutName: _nameController.text,
      workoutType: _typeController.text,
      duration: _durationController.text,
      workoutCategory: _categoryController.text,
      reps: int.tryParse(_repsController.text),
      sets: int.tryParse(_setsController.text),
      description: _descriptionController.text,
    );

    await _workoutService.createWorkoutWithGif(
      workout: newWorkout,
      gifFile: _pickedImage!,
      fileName: fileName,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout added successfully!')),
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
        title: const Text('Add Workout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.onSurface.withAlpha(26),
                    backgroundImage:
                    _pickedImage != null ? FileImage(_pickedImage!) : null,
                    child: _pickedImage == null
                        ? Icon(Icons.person,
                        size: 80, color: theme.colorScheme.onPrimary)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 140,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: theme.colorScheme.primary,
                    child: IconButton(
                      icon: Icon(Icons.edit,
                          size: 15, color: theme.colorScheme.onPrimary),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildTextField(controller: _nameController, labelText: 'Name'),
            const SizedBox(height: 20),
            _buildTextField(controller: _typeController, labelText: 'Type'),
            const SizedBox(height: 20),
            _buildTextField(
                controller: _durationController,
                labelText: 'Duration'),
            const SizedBox(height: 20),
            _buildTextField(
                controller: _categoryController, labelText: 'Category'),
            const SizedBox(height: 20),
            _buildTextField(
                controller: _repsController,
                labelText: 'Reps',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(
                controller: _setsController,
                labelText: 'Sets',
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(
                controller: _descriptionController,
                labelText: 'Description',
                maxLines: 5),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _addWorkout,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
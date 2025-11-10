import 'dart:io';
import 'package:flutter/material.dart';
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout updated successfully!')),
    );

    Navigator.pop(context);
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
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit Workout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                    backgroundColor: Colors.grey,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (_currentGifUrl != null
                        ? NetworkImage(_currentGifUrl!)
                        : null) as ImageProvider?,
                    child: _pickedImage == null && _currentGifUrl == null
                        ? const Icon(Icons.person,
                        size: 80, color: Colors.white)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 140,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.edit,
                          size: 15, color: Colors.white),
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
                labelText: 'Duration',
                keyboardType: TextInputType.number),
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
              onPressed: _editWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Edit', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

// Optional: A simple model to hold workout data.
// You might already have this from your other files.
class WorkoutItem {
  final String name;
  final String type;
  final String duration;
  final String category;
  final String reps;
  final String sets;
  final String description;

  WorkoutItem({
    required this.name,
    required this.type,
    required this.duration,
    required this.category,
    required this.reps,
    required this.sets,
    required this.description,
  });
}

class EditWorkoutPage extends StatefulWidget {
  // Pass the workout item to be edited to this page
  final WorkoutItem workoutToEdit;

  const EditWorkoutPage({super.key, required this.workoutToEdit});

  @override
  State<EditWorkoutPage> createState() => _EditWorkoutPageState();
}

class _EditWorkoutPageState extends State<EditWorkoutPage> {
  // Controllers to manage text field input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate the text fields with the data from the workoutToEdit object
    _nameController.text = widget.workoutToEdit.name;
    _typeController.text = widget.workoutToEdit.type;
    _durationController.text = widget.workoutToEdit.duration;
    _categoryController.text = widget.workoutToEdit.category;
    _repsController.text = widget.workoutToEdit.reps;
    _setsController.text = widget.workoutToEdit.sets;
    _descriptionController.text = widget.workoutToEdit.description;
  }

  // Function to handle the "Edit" button press
  void _editWorkout() {
    // Collect the updated data from the controllers
    String newName = _nameController.text;
    String newType = _typeController.text;
    String newDuration = _durationController.text;
    String newCategory = _categoryController.text;
    String newReps = _repsController.text;
    String newSets = _setsController.text;
    String newDescription = _descriptionController.text;

    // You would add validation and API calls here to update the workout
    print('Editing workout: ${widget.workoutToEdit.name}');
    print('New Name: $newName');
    // ... print other updated fields

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout updated successfully!')),
    );

    // After updating, navigate back
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Dispose of all controllers
    _nameController.dispose();
    _typeController.dispose();
    _durationController.dispose();
    _categoryController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // A reusable helper function to build a text field
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
            Navigator.pop(context); // Navigate back to the previous screen
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
            // Profile image with edit icon
            Stack(
              alignment: Alignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 80, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 140, // Adjust this value to position the icon
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 15, color: Colors.white),
                      onPressed: () {
                        // Handle image selection logic
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Form fields
            _buildTextField(controller: _nameController, labelText: 'Name'),
            const SizedBox(height: 20),
            _buildTextField(controller: _typeController, labelText: 'Type'),
            const SizedBox(height: 20),
            _buildTextField(controller: _durationController, labelText: 'Duration', keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(controller: _categoryController, labelText: 'Category'),
            const SizedBox(height: 20),
            _buildTextField(controller: _repsController, labelText: 'Reps', keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(controller: _setsController, labelText: 'Sets', keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(controller: _descriptionController, labelText: 'Description', maxLines: 5),
            const SizedBox(height: 40),

            // Edit button
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
import 'package:flutter/material.dart';

// Import your adminworkout.dart file here to enable navigation
import 'adminAddWorkout.dart';

class AddWorkoutPage extends StatefulWidget {
  const AddWorkoutPage({super.key});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  // Controllers for all the form text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Function to handle the "Add" button press
  void _addWorkout() {
    // You would add validation and API calls here
    print('Adding new workout:');
    print('Name: ${_nameController.text}');
    print('Type: ${_typeController.text}');
    print('Duration: ${_durationController.text}');
    print('Category: ${_categoryController.text}');
    print('Reps: ${_repsController.text}');
    print('Sets: ${_setsController.text}');
    print('Description: ${_descriptionController.text}');

    // Show a confirmation message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout added successfully!')),
    );

    // After adding, you can clear the text fields
    _nameController.clear();
    _typeController.clear();
    _durationController.clear();
    _categoryController.clear();
    _repsController.clear();
    _setsController.clear();
    _descriptionController.clear();
  }

  @override
  void dispose() {
    // Dispose of all controllers to free up memory
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
            // This will navigate back to the previous screen (adminworkout.dart)
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Add Workout',
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
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 140, // Adjust this value to position the icon correctly
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

            // Add button
            ElevatedButton(
              onPressed: _addWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
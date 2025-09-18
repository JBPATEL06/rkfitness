import 'package:flutter/material.dart';

class BmiPage extends StatefulWidget {
  const BmiPage({super.key});

  @override
  State<BmiPage> createState() => _BmiPageState();
}

class _BmiPageState extends State<BmiPage> {
  // 1. Define variables to hold the user inputs and the result.
  String _gender = 'Male';
  int _age = 20;
  double _weight = 60.0;
  double _height = 171.0;
  double _bmiResult = 0.0;
  bool _showResult = false;

  // 2. The core function to calculate BMI.
  void _calculateBmi() {
    double heightInMeters = _height / 100;
    setState(() {
      _bmiResult = _weight / (heightInMeters * heightInMeters);
      _showResult = true;
    });
  }

  // 3. The function to reset the calculator and hide the result.
  void _resetCalculator() {
    setState(() {
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('BMI Calculator',style: TextStyle(color: Colors.white),)),
        backgroundColor: Colors.red[700],
      ),
      body: _showResult
          ? Center(
        // The result screen
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Your BMI is', style: TextStyle(fontSize: 24)),
            Text(
              _bmiResult.toStringAsFixed(1), // Display with one decimal place
              style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700]),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _resetCalculator,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15)),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: _calculateBmi,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15)),
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        // The input screen
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Gender selection
            Row(
              children: [
                _buildGenderCard('Male'),
                const SizedBox(width: 10),
                _buildGenderCard('Female'),
              ],
            ),
            const SizedBox(height: 20),
            // Age & Weight
            Row(
              children: [
                _buildInputCard('Age', _age, (value) {
                  setState(() => _age = value.toInt());
                }, min: 1, max: 120),
                const SizedBox(width: 10),
                _buildInputCard('Weight(KG)', _weight, (value) {
                  setState(() => _weight = value);
                }, min: 1.0, max: 200.0),
              ],
            ),
            const SizedBox(height: 20),
            // Height slider
            _buildHeightSlider(),
            const SizedBox(height: 30),
            // Update button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _calculateBmi,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('Update',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets to build the UI components ---

  Widget _buildGenderCard(String gender) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _gender = gender;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _gender == gender ? Colors.red[700] : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                gender == 'Male' ? Icons.male : Icons.female,
                size: 50,
                color: _gender == gender ? Colors.white : Colors.black,
              ),
              const SizedBox(height: 10),
              Text(
                gender,
                style: TextStyle(
                  fontSize: 18,
                  color: _gender == gender ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(String label, dynamic value, Function(dynamic) onChanged,
      {double? min, double? max}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 18)),
            Text(
              value is double ? value.toStringAsFixed(0) : value.toString(),
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconButton(
                    Icons.remove,
                        () => onChanged(value - (value is double ? 1.0 : 1)),
                    (value == min)),
                const SizedBox(width: 10),
                _buildIconButton(
                    Icons.add,
                        () => onChanged(value + (value is double ? 1.0 : 1)),
                    (value == max)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed, bool disabled) {
    return FloatingActionButton(
      onPressed: disabled ? null : onPressed,
      mini: true,
      backgroundColor: disabled ? Colors.grey[400] : Colors.red,
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildHeightSlider() {
    return Column(
      children: [
        const Text(
          'Height(Cm)',
          style: TextStyle(fontSize: 18),
        ),
        Text(
          _height.toStringAsFixed(0),
          style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.red[700]),
        ),
        Slider(
          value: _height,
          min: 100,
          max: 220,
          divisions: 120,
          activeColor: Colors.red,
          inactiveColor: Colors.red[100],
          onChanged: (double newValue) {
            setState(() {
              _height = newValue;
            });
          },
        ),
      ],
    );
  }
}
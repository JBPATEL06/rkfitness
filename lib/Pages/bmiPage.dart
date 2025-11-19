import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ADDED
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BmiPage extends StatefulWidget {
  const BmiPage({super.key});

  @override
  State<BmiPage> createState() => _BmiPageState();
}

class _BmiPageState extends State<BmiPage> {
  String _gender = 'Male';
  int _age = 20;
  double _weight = 60.0;
  double _height = 171.0;
  double _bmiResult = 0.0;
  bool _showResult = false;
  bool _isLoading = true;

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userGmail = Supabase.instance.client.auth.currentUser?.email;
    if (userGmail == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final user = await _userService.getUser(userGmail);
    if (user != null && mounted) {
      setState(() {
        _weight = user.weight ?? _weight;
        _height = user.height ?? _height;
        _age = user.age ?? _age;
        _gender = user.gender ?? _gender;
        _bmiResult = user.bmi ?? 0.0;
        _isLoading = false;
      });
    } else if (mounted) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _calculateAndUpdateBmi() async {
    final userGmail = Supabase.instance.client.auth.currentUser?.email;
    if (userGmail == null) return;

    double heightInMeters = _height / 100;
    _bmiResult = _weight / (heightInMeters * heightInMeters);

    final updatedUser = UserModel(
      gmail: userGmail,
      weight: _weight,
      height: _height,
      age: _age,
      gender: _gender,
      bmi: _bmiResult,
    );

    await _userService.updateUser(updatedUser);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('BMI data updated successfully!'),
        ),
      );
      setState(() {
        _showResult = true;
      });
    }
  }

  void _resetCalculator() {
    setState(() {
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator',),
      ),
      body: _showResult
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your BMI is', style: theme.textTheme.headlineSmall),
            Text(
              _bmiResult.toStringAsFixed(1),
              style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _resetCalculator,
                  style: theme.elevatedButtonTheme.style,
                  child: const Text('Back'),
                ),
              ],
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Row(
              children: [
                _buildGenderCard(context, 'Male'),
                SizedBox(width: 10.w),
                _buildGenderCard(context, 'Female'),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                _buildInputCard(context, 'Age', _age, (value) {
                  setState(() => _age = value.toInt());
                }, min: 1, max: 120),
                SizedBox(width: 10.w),
                _buildInputCard(context, 'Weight(KG)', _weight, (value) {
                  setState(() => _weight = value);
                }, min: 1.0, max: 200.0),
              ],
            ),
            SizedBox(height: 20.h),
            _buildHeightSlider(context),
            SizedBox(height: 30.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _calculateAndUpdateBmi,
                child: const Text('Calculate & Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(BuildContext context, String gender) {
    final theme = Theme.of(context);
    final isSelected = _gender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _gender = gender;
          });
        },
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : theme.inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            children: [
              Icon(
                gender == 'Male' ? Icons.male : Icons.female,
                size: 50.w,
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
              ),
              SizedBox(height: 10.h),
              Text(
                gender,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, String label, dynamic value, Function(dynamic) onChanged,
      {double? min, double? max}) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Text(label, style: theme.textTheme.titleMedium),
            Text(
              value is double ? value.toStringAsFixed(0) : value.toString(),
              style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconButton(
                    theme,
                    Icons.remove,
                        () => onChanged(value - (value is double ? 1.0 : 1)),
                    (value == min)),
                SizedBox(width: 10.w),
                _buildIconButton(
                    theme,
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

  Widget _buildIconButton(ThemeData theme, IconData icon, VoidCallback onPressed, bool disabled) {
    return FloatingActionButton(
      onPressed: disabled ? null : onPressed,
      mini: true,
      backgroundColor: disabled ? Colors.grey.shade400 : theme.colorScheme.primary,
      child: Icon(icon, color: theme.colorScheme.onPrimary, size: 20.w), // CONVERTED
    );
  }

  Widget _buildHeightSlider(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Height(Cm)',
          style: theme.textTheme.titleMedium,
        ),
        Text(
          _height.toStringAsFixed(0),
          style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary),
        ),
        Slider(
          value: _height,
          min: 100,
          max: 220,
          divisions: 120,
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.primary.withAlpha(77),
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
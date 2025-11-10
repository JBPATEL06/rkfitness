import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rkfitness/customWidgets/weekdays.dart';

class RedText extends StatelessWidget {
  const RedText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const Text('');
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text[0],
            style: const TextStyle(
              color: Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: text.substring(1),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

Days getCurrentDay() {
  int weekday = DateTime.now().weekday;
  // Assuming Days is an enum where Days.values[0] is Monday (ISO 8601 standard)
  return Days.values[weekday - 1];
}

String stringgetCurrentDay() {
  DateTime now = DateTime.now();
  return DateFormat('EEE').format(now).toUpperCase();
}
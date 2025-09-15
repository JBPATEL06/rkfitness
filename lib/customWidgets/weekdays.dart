// day_selector.dart
import 'package:flutter/material.dart';

enum Days { MON, TUE, WED, THU, FRI, SAT, SUN }

class Weekdays extends StatelessWidget {
  final Set<Days> selectedDay;

  const Weekdays({
    super.key,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(13),
        ),
        child: SegmentedButton<Days>(
          selected: selectedDay,
          onSelectionChanged: null,
          segments: const <ButtonSegment<Days>>[
            ButtonSegment<Days>(value: Days.MON, label: Text('MON')),
            ButtonSegment<Days>(value: Days.TUE, label: Text('TUE')),
            ButtonSegment<Days>(value: Days.WED, label: Text('WED')),
            ButtonSegment<Days>(value: Days.THU, label: Text('THU')),
            ButtonSegment<Days>(value: Days.FRI, label: Text('FRI')),
            ButtonSegment<Days>(value: Days.SAT, label: Text('SAT')),
            ButtonSegment<Days>(value: Days.SUN, label: Text('SUN')),
          ],
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.red;
              }
              return Colors.transparent;
            }),
            foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.white;
              }
              return Colors.black;
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            side: MaterialStateProperty.all<BorderSide>(BorderSide.none),
          ),
          showSelectedIcon: false,
        ),
      ),
    );
  }
}
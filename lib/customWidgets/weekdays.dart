// day_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ADDED

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
      padding: EdgeInsets.symmetric(horizontal: 13.w), // CONVERTED
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(13.r), // CONVERTED
        ),
        child: SegmentedButton<Days>(
          selected: selectedDay,
          onSelectionChanged: null,
          segments: const <ButtonSegment<Days>>[
            // NOTE: Text size in ButtonSegment is often controlled by Theme, 
            // but we can ensure responsiveness through the button style.
            ButtonSegment<Days>(value: Days.MON, label: Text('MON')),
            ButtonSegment<Days>(value: Days.TUE, label: Text('TUE')),
            ButtonSegment<Days>(value: Days.WED, label: Text('WED')),
            ButtonSegment<Days>(value: Days.THU, label: Text('THU')),
            ButtonSegment<Days>(value: Days.FRI, label: Text('FRI')),
            ButtonSegment<Days>(value: Days.SAT, label: Text('SAT')),
            ButtonSegment<Days>(value: Days.SUN, label: Text('SUN')),
          ],
          style: ButtonStyle(
            textStyle: MaterialStateProperty.resolveWith<TextStyle>((Set<MaterialState> states) {
              return TextStyle(fontSize: 14.sp); // CONVERTED Text Size
            }),
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
                borderRadius: BorderRadius.circular(13.r), // CONVERTED
              ),
            ),
            side: MaterialStateProperty.all<BorderSide>(BorderSide.none),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h)),
          ),
          showSelectedIcon: false,
        ),
      ),
    );
  }
}
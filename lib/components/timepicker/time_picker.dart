import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:numberpicker/numberpicker.dart';

class NumberPage extends StatefulWidget {
  const NumberPage({super.key});
  @override
  State<NumberPage> createState() => _NumberPageState();
}

class _NumberPageState extends State<NumberPage> {
  var hour = 0;
  var minute = 0;
  var timeFormat = "AM";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NumberPickerWidget(
        hour: hour,
        minute: minute,
        onHourChanged: (value) {
          setState(() {
            hour = value;
          });
        },
        onMinuteChanged: (value) {
          setState(() {
            minute = value;
          });
        },
      ),
    );
  }
}

class NumberPickerWidget extends StatelessWidget {
  final int hour;
  final int minute;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  const NumberPickerWidget({
    super.key,
    required this.hour,
    required this.minute,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.3,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 5,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NumberPicker(
                  minValue: 0,
                  maxValue: 23,
                  value: hour,
                  zeroPad: true,
                  infiniteLoop: true,
                  itemWidth: 55,
                  itemHeight: 50,
                  onChanged: onHourChanged,
                  textStyle: TextStyle(
                      color: AppColors.putih.withOpacity(0.5), fontSize: 20),
                  selectedTextStyle: TextStyle(
                    color: AppColors.putih,
                    fontSize: 24,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.putih),
                      bottom: BorderSide(color: AppColors.putih),
                    ),
                  ),
                ),
                NumberPicker(
                  minValue: 0,
                  maxValue: 59,
                  value: minute,
                  zeroPad: true,
                  infiniteLoop: true,
                  itemWidth: 55,
                  itemHeight: 50,
                  onChanged: onMinuteChanged,
                  textStyle: TextStyle(
                    color: AppColors.putih.withOpacity(0.5),
                    fontSize: 20,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                  selectedTextStyle: TextStyle(
                    color: AppColors.putih,
                    fontSize: 24,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.putih),
                      bottom: BorderSide(color: AppColors.putih),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 80,
          )
        ],
      ),
    );
  }
}

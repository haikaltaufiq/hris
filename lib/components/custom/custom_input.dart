// lib/widgets/custom_input_field.dart
import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final Widget? suffixIcon;
  final VoidCallback? onTapIcon;
  final TextEditingController? controller;
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final InputDecoration inputStyle;
  final bool readOnly;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hint,
    this.suffixIcon,
    this.onTapIcon,
    this.controller,
    required this.labelStyle,
    required this.textStyle,
    required this.inputStyle,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTapIcon,
          child: AbsorbPointer(
            absorbing: onTapIcon != null,
            child: TextFormField(
              controller: controller,
              readOnly: readOnly,
              style: textStyle,
              decoration: inputStyle.copyWith(
                hintText: hint,
                suffixIcon: suffixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: suffixIcon,
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

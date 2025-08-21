import 'package:flutter/material.dart';
// ---------- Custom Camera Field ----------

/// ------------------------------
/// 3) CustomCameraField (form field dengan icon kamera + long press)
/// ------------------------------
class CustomCameraField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final InputDecoration inputStyle;

  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final Widget? suffixIcon;

  const CustomCameraField({
    super.key,
    required this.label,
    required this.hint,
    required this.labelStyle,
    required this.textStyle,
    required this.inputStyle,
    this.controller,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          onLongPressStart: (_) => onLongPressStart?.call(),
          onLongPressEnd: (_) => onLongPressEnd?.call(),
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              style: textStyle,
              readOnly: true,
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

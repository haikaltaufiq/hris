// lib/widgets/custom_input_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final Widget? suffixIcon;
  final VoidCallback? onTapIcon;
  final TextEditingController? controller;
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final InputDecoration inputStyle;
  final bool? readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

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
    this.inputFormatters,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        onTapIcon != null
            ? GestureDetector(
                onTap: onTapIcon,
                child: AbsorbPointer(
                  child: TextFormField(
                    readOnly: true,
                    controller: controller,
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
              )
            : TextFormField(
                controller: controller,
                style: textStyle,
                decoration: inputStyle.copyWith(hintText: hint),
              ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class CustomPasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final InputDecoration inputStyle;

  const CustomPasswordField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    required this.labelStyle,
    required this.textStyle,
    required this.inputStyle,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: widget.labelStyle),
        const SizedBox(height: 4),
        TextFormField(
          controller: widget.controller,
          style: widget.textStyle,
          obscureText: _obscureText,
          decoration: widget.inputStyle.copyWith(
            hintText: widget.hint,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: _toggleObscure,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

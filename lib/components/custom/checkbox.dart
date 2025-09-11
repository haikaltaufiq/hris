import 'package:flutter/material.dart';

class CheckBoxField extends StatelessWidget {
  final String hint;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final TextStyle textStyle;

  const CheckBoxField({
    super.key,
    required this.hint,
    required this.isChecked,
    required this.onChanged,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!isChecked),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: isChecked,
            onChanged: onChanged,
          ),
          Flexible(
            child: Text(
              hint,
              style: textStyle,
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

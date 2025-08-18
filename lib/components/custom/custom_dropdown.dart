import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
class CustomDropDownField extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> items;
  final String? value; 
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final InputDecoration inputStyle;
  final Color dropdownColor;
  final Color dropdownTextColor;
  final Color dropdownIconColor;
  final Color buttonColor;

  const CustomDropDownField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    this.value, 
    this.onChanged,
    this.validator,
    required this.labelStyle,
    required this.textStyle,
    required this.inputStyle,
    this.dropdownColor = Colors.white,
    this.dropdownTextColor = Colors.black,
    this.dropdownIconColor = Colors.black,
    this.buttonColor = const Color.fromARGB(0, 31, 31, 31),
  });

  @override
  State<CustomDropDownField> createState() => _CustomDropDownFieldState();
}

class _CustomDropDownFieldState extends State<CustomDropDownField> {
  @override
  Widget build(BuildContext context) {
    return _DropDownFieldBody(
      label: widget.label,
      hint: widget.hint,
      items: widget.items,
      value: widget.value, 
      onChanged: widget.onChanged,
      validator: widget.validator,
      labelStyle: widget.labelStyle,
      textStyle: widget.textStyle,
      inputStyle: widget.inputStyle,
      dropdownColor: widget.dropdownColor,
      dropdownTextColor: widget.dropdownTextColor,
      dropdownIconColor: widget.dropdownIconColor,
      buttonColor: widget.buttonColor,
    );
  }
}

class _DropDownFieldBody extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> items;
  final String? value; 
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final InputDecoration inputStyle;
  final Color dropdownColor;
  final Color dropdownTextColor;
  final Color dropdownIconColor;
  final Color buttonColor;

  const _DropDownFieldBody({
    required this.label,
    required this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    required this.labelStyle,
    required this.textStyle,
    required this.inputStyle,
    required this.dropdownColor,
    required this.dropdownTextColor,
    required this.dropdownIconColor,
    required this.buttonColor,
  });

  @override
  State<_DropDownFieldBody> createState() => _DropDownFieldBodyState();
}

class _DropDownFieldBodyState extends State<_DropDownFieldBody> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.value; 
  }

  @override
  void didUpdateWidget(covariant _DropDownFieldBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      selectedValue = widget.value; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: widget.labelStyle),
        const SizedBox(height: 4),
        DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: widget.inputStyle.copyWith(
              hintText: widget.hint,
            ),
            hint: Text(
              widget.hint,
              style: widget.textStyle.copyWith(
                color: widget.dropdownTextColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            items: widget.items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: widget.textStyle.copyWith(
                        color: widget.dropdownTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            value: selectedValue, 
            onChanged: (value) {
              setState(() {
                selectedValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
            validator: widget.validator,
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: widget.dropdownColor,
              ),
              maxHeight: 200,
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: WidgetStateProperty.all(6),
                thumbVisibility: WidgetStateProperty.all(true),
              ),
            ),
            iconStyleData: IconStyleData(
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              iconEnabledColor: widget.dropdownIconColor,
              iconDisabledColor: Colors.grey,
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              overlayColor: WidgetStatePropertyAll(Colors.transparent),
              padding: EdgeInsets.symmetric(horizontal: 14),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

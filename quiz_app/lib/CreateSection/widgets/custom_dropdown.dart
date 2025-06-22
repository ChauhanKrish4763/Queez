import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

class CustomDropdown extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String hintText;
  final String? Function(String?)? validator;
  final bool autoValidate;
  final Function(String?) onChanged;
  final double? menuMaxHeight;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hintText,
    this.validator,
    this.autoValidate = false,
    required this.onChanged,
    this.menuMaxHeight,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        autovalidateMode: widget.autoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        value: widget.value,
        isExpanded: true,
        icon: AnimatedRotation(
          turns: _isOpen ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
        iconSize: 24,
        elevation: 2,
        dropdownColor: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        menuMaxHeight: widget.menuMaxHeight ?? 300,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        items: widget.items.map((item) {
          final isSelected = widget.value == item;
          return DropdownMenuItem<String>(
            value: item,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        onChanged: widget.onChanged,
        validator: widget.validator,
        onTap: () {
          setState(() {
            _isOpen = true;
          });
        },
        selectedItemBuilder: (BuildContext context) {
          return widget.items.map<Widget>((String item) {
            return Text(
              item,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool autoValidate;
  final double? width; // New width parameter

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.validator,
    this.autoValidate = false,
    this.width, // Optional width parameter
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: width, // Apply width if provided
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
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            autovalidateMode: autoValidate 
                ? AutovalidateMode.onUserInteraction 
                : AutovalidateMode.disabled,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
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
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
              errorStyle: const TextStyle(height: 0),
            ),
          ),
        ),
      ],
    );
  }
}

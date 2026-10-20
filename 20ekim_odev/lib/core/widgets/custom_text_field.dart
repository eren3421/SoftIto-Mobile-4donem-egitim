import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? initialValue;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.initialValue,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.silverText,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            initialValue: initialValue,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            onTap: onTap,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

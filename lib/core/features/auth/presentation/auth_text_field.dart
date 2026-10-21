import 'package:flutter/material.dart';
import 'package:notes_app/core/theme/app_radius.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.onSuffixPressed,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: theme.textTheme.bodyMedium,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(onPressed: onSuffixPressed, icon: Icon(suffixIcon)),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NotedRadius.sm),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NotedRadius.sm),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NotedRadius.sm),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NotedRadius.sm),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NotedRadius.sm),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
      ),
    );
  }
}

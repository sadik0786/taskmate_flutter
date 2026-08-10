import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatefulWidget {
  final String? labelText;
  final bool isRequired;
  final String hintText;
  final IconData? prefixIcon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isEnabled;
  final bool isDense;
  final int? maxLength;
  final String? pattern;
  final bool isObscure;
  final int? maxLines;
  final Color?
  fillColor; // Keeping for backwards compatibility but not explicitly needed
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    this.labelText,
    this.isRequired = false,
    required this.hintText,
    this.prefixIcon,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isEnabled = true,
    this.isDense = false,
    this.maxLength,
    this.pattern,
    this.isObscure = false,
    this.maxLines,
    this.fillColor,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Row(
            children: [
              Text(widget.labelText!, style: theme.textTheme.labelLarge),
              if (widget.isRequired)
                Text(
                  " *",
                  style: TextStyle(
                    color: errorColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          enabled: widget.isEnabled,
          obscureText: _obscureText,
          maxLength: widget.maxLength,
          maxLines: widget.isObscure ? 1 : (widget.maxLines ?? 1),
          onChanged: widget.onChanged,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: widget.isEnabled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          decoration: InputDecoration(
            fillColor: widget.fillColor ?? theme.inputDecorationTheme.fillColor,
            hintText: widget.hintText,
            isDense: widget.isDense,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: widget.isEnabled
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface.withOpacity(0.3),
                  )
                : null,
            suffixIcon: widget.isObscure
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
          validator:
              widget.validator ??
              (val) {
                if (widget.isRequired && (val == null || val.trim().isEmpty)) {
                  return "${widget.labelText ?? 'Field'} cannot be empty";
                }
                if (widget.pattern != null &&
                    val != null &&
                    !RegExp(widget.pattern!).hasMatch(val.trim())) {
                  return "Invalid ${widget.labelText?.toLowerCase() ?? 'value'}";
                }
                return null;
              },
        ),
      ],
    );
  }
}

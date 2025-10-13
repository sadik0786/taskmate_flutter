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
  final String? pattern; // optional regex pattern
  final bool isObscure; // password field

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Row(
            children: [
              Text(
                widget.labelText!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400, fontSize: 15.sp),
              ),
              if (widget.isRequired)
                Text(
                  " *",
                  style: TextStyle(color: Colors.red, fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          SizedBox(height: 6.h),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          enabled: widget.isEnabled,
          obscureText: _obscureText,
          maxLength: widget.maxLength,
          style: TextStyle(fontSize: 16.sp, color: widget.isEnabled ? null : Colors.grey[600]),
          decoration: InputDecoration(
            hintText: widget.hintText,
            isDense: widget.isDense,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: widget.isEnabled ? null : Colors.grey[600])
                : null,
            suffixIcon: widget.isObscure
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
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

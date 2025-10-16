import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_mate/core/theme.dart';

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
  final Color? fillColor;

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
    this.fillColor = ThemeClass.darkCardColor,
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
                ).textTheme.titleMedium,
              ),
              if (widget.isRequired)
                Text(
                  " *",
                  style: TextStyle(
                    color: ThemeClass.errorColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
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
          style: TextStyle(
            fontSize: 16.sp,
            color: widget.isEnabled ? ThemeClass.textWhite : ThemeClass.textBlack,
          ),
          decoration: InputDecoration(
            fillColor: widget.fillColor,
            hintText: widget.hintText,
            hintStyle: TextStyle(color: ThemeClass.lightBgColor.withAlpha(80), fontSize: 14.sp),
            isDense: widget.isDense,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: widget.isEnabled ? ThemeClass.textWhite : ThemeClass.textBlack,
                  )
                : null,
            suffixIcon: widget.isObscure
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: ThemeClass.textWhite,
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
            counterStyle: TextStyle(color: Colors.white70, fontSize: 12.sp),
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_mate/core/theme.dart';

class CustomDateField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String? labelText;
  final bool isRequired;
  final IconData prefixIcon;
  final String hintText;
  final String? Function(DateTime?)? validator;
  final Color? fillColor;

  const CustomDateField({
    super.key,
    required this.selectedDate,
    required this.onTap,
    this.labelText,
    this.isRequired = false,
    required this.prefixIcon,
    required this.hintText,
    this.validator,
    this.fillColor = ThemeClass.darkCardColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = selectedDate != null
        ? "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"
        : hintText;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Row(
            children: [
              Text(labelText!, style: Theme.of(context).textTheme.titleMedium),
              if (isRequired)
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
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark ? ThemeClass.textWhite : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: displayText,
                hintStyle: TextStyle(
                  color: selectedDate != null
                      ? ThemeClass.textWhite
                      : ThemeClass.textWhite.withAlpha(80),
                  fontSize: 16.sp,
                ),
                prefixIcon: Icon(prefixIcon, color: ThemeClass.textWhite),
                filled: true,
                fillColor: fillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
              ),
              validator: (val) {
                if (isRequired && selectedDate == null) {
                  return validator?.call(selectedDate) ?? "Please select a date";
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}

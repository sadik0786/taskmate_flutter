import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_mate/core/theme.dart';

class CustomTimeField extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final VoidCallback onTap;
  final String? labelText;
  final bool isRequired;
  final IconData prefixIcon;
  final String hintText;
  final String? Function(TimeOfDay?)? validator;
  final Color? fillColor;

  const CustomTimeField({
    super.key,
    required this.selectedTime,
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
    final displayText = selectedTime != null ? selectedTime!.format(context) : hintText;
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
              style: TextStyle(fontSize: 16.sp, color: ThemeClass.textWhite),
              decoration: InputDecoration(
                hintText: displayText,
                hintStyle: TextStyle(
                  color: selectedTime != null
                      ? ThemeClass.textWhite
                      : ThemeClass.textWhite.withAlpha(80),
                  fontSize: 14.sp,
                ),
                filled: true,
                fillColor: fillColor,
                prefixIcon: Icon(prefixIcon, color: ThemeClass.textWhite),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
              ),
              validator: (val) {
                if (isRequired && selectedTime == null) {
                  return validator?.call(selectedTime) ?? "Please select a time";
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

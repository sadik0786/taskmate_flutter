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
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = selectedDate != null
        ? "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"
        : hintText;

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
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: displayText,
                hintStyle: TextStyle(
                  color: selectedDate != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 16.sp,
                ),
                prefixIcon: Icon(
                  prefixIcon,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor:
                    fillColor ??
                    Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: 12.w,
                ),
              ),
              validator: (val) {
                if (isRequired && selectedDate == null) {
                  return validator?.call(selectedDate) ??
                      "Please select a date";
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

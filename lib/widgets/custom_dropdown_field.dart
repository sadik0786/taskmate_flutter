import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_mate/core/theme.dart';

class CustomDropdownField<T> extends StatefulWidget {
  final String? labelText;
  final bool isRequired; 
  final String hintText;
  final IconData prefixIcon;
  final List<Map<String, dynamic>> items;
  final String valueKey;
  final String labelKey;
  final T? value;
  final bool isLoading;
  final bool isEnabled;
  final Color fillColor;
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const CustomDropdownField({
    super.key,
    this.labelText,
    this.isRequired = false,
    required this.hintText,
    required this.prefixIcon,
    required this.items,
    required this.valueKey,
    required this.labelKey,
    this.value,
    this.onChanged,
    this.validator,
    this.isLoading = false,
    this.isEnabled = true,
    this.fillColor = ThemeClass.textBlack,
  });

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  bool _isDropdownOpen = false;
  @override
  Widget build(BuildContext context) {

    if (widget.isLoading) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(strokeWidth: 2.w),
            ),
            SizedBox(width: 12.w),
            Text("Loading...", style: TextStyle(fontSize: 16.sp)),
          ],
        ),
      );
    }

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
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400, fontSize: 15.sp),
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
        DropdownButtonFormField2<T>(
          isExpanded: true,
          value: widget.value,
          hint: Text(
            widget.hintText,
            style: TextStyle(
              color: widget.isEnabled == false
                  ? ThemeClass.textWhite
                  : ThemeClass.textWhite.withAlpha(80),
              fontSize: 16.sp,
            ),
          ),
          items: widget.items.map((item) {
            return DropdownMenuItem<T>(
              value: item[widget.valueKey] as T,
              child: Text(
                item[widget.labelKey].toString(),
                style: TextStyle(
                  color: widget.isEnabled ? ThemeClass.textWhite : ThemeClass.textBlack,
                  fontSize: 16.sp,
                ),
              ),
            );
          }).toList(),
          onMenuStateChange: (isOpen) {
            // 🔹 Listen for open/close events
            setState(() => _isDropdownOpen = isOpen);
          },
          onChanged: widget.isEnabled ? widget.onChanged : null,
          validator:
              widget.validator ??
              (val) {
                if (widget.isRequired && val == null) {
                  return "Please select ${widget.labelText?.toLowerCase() ?? 'a value'}";
                }
                return null;
              },
          decoration: InputDecoration(
            prefixIcon: Icon(
              widget.prefixIcon,
              color: widget.isEnabled ? ThemeClass.textWhite : ThemeClass.textBlack,
            ),
            filled: true,
            fillColor: widget.isEnabled ? widget.fillColor : ThemeClass.textBlack,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          ),
          iconStyleData: IconStyleData(
            icon: AnimatedRotation(
              turns: _isDropdownOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: widget.isEnabled ? ThemeClass.textWhite : ThemeClass.textBlack,
                size: 24.sp,
              ),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 300.h,
            width: MediaQuery.of(context).size.width - 35.w,
            decoration: BoxDecoration(
              color: widget.isEnabled ? ThemeClass.textBlack : ThemeClass.textBlack,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            height: 28.h,
            width: double.infinity,
          ),
        ),
      ],
    );
  }
}

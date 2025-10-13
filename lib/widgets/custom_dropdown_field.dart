import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String? labelText; // Optional label above dropdown
  final bool isRequired; // Show * for required fields
  final String hintText;
  final IconData prefixIcon;
  final List<Map<String, dynamic>> items;
  final String valueKey;
  final String labelKey;
  final T? value;
  final bool isLoading;
  final bool isEnabled;
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
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
        if (labelText != null) ...[
          Row(
            children: [
              Text(
                labelText!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400, fontSize: 15.sp),
              ),
              if (isRequired)
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
          value: value,
          hint: Text(
            hintText,
            style: TextStyle(
              color: isEnabled == false ? Colors.grey[600] : Colors.black,
              fontSize: 16.sp,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item[valueKey] as T,
              child: Text(
                item[labelKey].toString(),
                style: TextStyle(color: isEnabled ? null : Colors.grey, fontSize: 16.sp),
              ),
            );
          }).toList(),
          onChanged: isEnabled ? onChanged : null,
          validator:
              validator ??
              (val) {
                if (isRequired && val == null) {
                  return "Please select ${labelText?.toLowerCase() ?? 'a value'}";
                }
                return null;
              },
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, color: isEnabled ? null : Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 300.h,
            width: MediaQuery.of(context).size.width - 40.w,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
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

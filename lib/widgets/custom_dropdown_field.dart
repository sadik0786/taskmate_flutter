import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  final Color? fillColor;
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
    this.fillColor,
  });

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  bool _isDropdownOpen = false;
  late final ValueNotifier<T?> _valueNotifier;

  @override
  void initState() {
    super.initState();
    _valueNotifier = ValueNotifier<T?>(widget.value);
  }

  @override
  void didUpdateWidget(covariant CustomDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _valueNotifier.value = widget.value;
    }
  }

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 15.sp,
                ),
              ),
              if (widget.isRequired)
                Text(
                  " *",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            return DropdownButtonFormField2<T>(
              isExpanded: true,
              valueListenable: _valueNotifier,
              hint: Text(
                widget.hintText,
                style: TextStyle(
                  color: widget.isEnabled == false
                      ? Theme.of(context).disabledColor
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 14.sp,
                ),
              ),
              items: widget.items.map((item) {
                return DropdownItem<T>(
                  value: item[widget.valueKey] as T,
                  child: Text(
                    item[widget.labelKey].toString(),
                    style: TextStyle(
                      color: widget.isEnabled
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).disabledColor,
                      fontSize: 14.sp,
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
                prefixIconConstraints: BoxConstraints(
                  minWidth: 48.w,
                  minHeight: 48.h,
                ),
                prefixIcon: SizedBox(
                  width: 48.w,
                  child: Icon(
                    widget.prefixIcon,
                    color: widget.isEnabled
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).disabledColor,
                  ),
                ),
                filled: true,
                fillColor: widget.isEnabled
                    ? (widget.fillColor ??
                          Theme.of(context).inputDecorationTheme.fillColor)
                    : Theme.of(context).disabledColor.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: 12.w,
                ),
              ),
              iconStyleData: IconStyleData(
                icon: AnimatedRotation(
                  turns: _isDropdownOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: widget.isEnabled
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).disabledColor,
                    size: 24.sp,
                  ),
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 300.h,
                width: constraints.maxWidth,
                offset: Offset(
                  -33.w,
                  0.h,
                ), // Negative offset shifts list to the left to cover prefixIcon
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              buttonStyleData: FormFieldButtonStyleData(
                padding: EdgeInsets.zero,
                height: 28.h,
              ),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_mate/core/theme.dart';

class CustomChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const CustomChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : (isDark ? Colors.white70 : ThemeClass.textBlack),
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
        ),
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      selectedColor: isDark ? Colors.blueGrey[600] : ThemeClass.primaryGreen,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: selected
              ? (isDark ? Colors.blueGrey : ThemeClass.warningColor)
              : (isDark ? Colors.white24 : ThemeClass.darkBlue),
          width: 1.2,
        ),
      ),
      elevation: selected ? 3 : 0,
      pressElevation: 1,
      visualDensity: VisualDensity.compact,
    );
  }
}

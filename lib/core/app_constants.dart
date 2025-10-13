import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/theme.dart';

class AppConstants {
  static const int transitionDuration = 320;
  static const Transition transition = Transition.rightToLeft;

  static List<BoxShadow> boxShadow = [
    const BoxShadow(color: Color.fromARGB(25, 0, 0, 0), blurRadius: 3, offset: Offset(2, 2)),
  ];
  static InputBorder enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: ThemeClass.textSecondaryLight),
  );
  static InputBorder focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: ThemeClass.textSecondaryLight),
  );
  static InputBorder errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: ThemeClass.errorColor),
  );

  static const LinearGradient appGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
  );
}

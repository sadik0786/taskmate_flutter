import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/theme.dart';

class AppConstants {
  static int get transitionDuration =>
      (GetPlatform.isWeb || GetPlatform.isDesktop) ? 0 : 320;
  static Transition get transition =>
      (GetPlatform.isWeb || GetPlatform.isDesktop)
      ? Transition.noTransition
      : Transition.rightToLeft;

  static List<BoxShadow> boxShadow = [
    const BoxShadow(
      color: Color.fromARGB(25, 0, 0, 0),
      blurRadius: 3,
      offset: Offset(2, 2),
    ),
  ];
  static InputBorder enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: ThemeClass.lightBgColor),
  );
  static InputBorder focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: ThemeClass.lightBgColor),
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

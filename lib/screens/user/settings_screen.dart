import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/controllers/theme_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/widgets/base_layout.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_text_field.dart';
import 'package:task_mate/widgets/responsive_desktop_wrappers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _savedPin;

  @override
  void initState() {
    super.initState();
    _loadSavedPin();
  }

  Future<void> _loadSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPin = prefs.getString("appLockPin");
    });
  }

  void _showSetPinBottomSheet() {
    final TextEditingController pinController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
        ),
        child: ResponsiveFormWrapper(
          maxWidth: 600,
          padding: EdgeInsets.zero,
          wrapInCardOnDesktop: false,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _savedPin == null
                      ? "Set App Lock PIN"
                      : "Change App Lock PIN",
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                SizedBox(height: 20.h),
                CustomTextField(
                  labelText: "Set PIN",
                  hintText: "Enter 4-digit number",
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  isObscure: true,
                  maxLength: 4,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "PIN required";
                    if (value.length != 4) return "PIN must be 4 digits";
                    return null;
                  },
                ),
                CustomTextField(
                  labelText: "Confirm Set PIN",
                  hintText: "Enter 4-digit number",
                  controller: confirmController,
                  keyboardType: TextInputType.number,
                  isObscure: true,
                  maxLength: 4,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Confirm your PIN";
                    }
                    if (value != pinController.text) return "PINs do not match";
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                CustomButton(
                  text: _savedPin == null ? "Save PIN" : "Update PIN",
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString("appLockPin", pinController.text);
                      setState(() {
                        _savedPin = pinController.text;
                      });
                      Navigator.pop(Get.context!);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _savedPin == null
                                ? "PIN set successfully!"
                                : "PIN updated successfully!",
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return BaseLayout(
      title: "Settings",
      child: ResponsiveFormWrapper(
        maxWidth: 800,
        padding: EdgeInsets.zero,
        wrapInCardOnDesktop: false,
        child: Column(
          children: [
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: Card(
                color: Theme.of(context).cardColor,
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Appearance",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Obx(
                                () => Icon(
                                  themeController.isDarkMode.value
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                "Dark Mode",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          Obx(
                            () => Switch(
                              value: themeController.isDarkMode.value,
                              onChanged: (value) {
                                themeController.toggleTheme();
                              },
                              activeColor: ThemeClass.textWhite,
                              activeTrackColor: Theme.of(context).primaryColor,
                              inactiveThumbColor: Theme.of(
                                context,
                              ).disabledColor,
                              inactiveTrackColor: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 30.h),
                      Text(
                        "Security",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.lock,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        title: Text(
                          _savedPin == null
                              ? "Set App Lock PIN"
                              : "Change App Lock PIN",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).dividerColor,
                        ),
                        onTap: _showSetPinBottomSheet,
                      ),
                      Divider(height: 30.h),
                      Text(
                        "General",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.notifications_active,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        title: Text(
                          "Notifications",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).dividerColor,
                        ),
                        onTap: () {
                          Get.snackbar(
                            "Info",
                            "Notifications setting coming soon!",
                            backgroundColor: Theme.of(context).primaryColor,
                            colorText: ThemeClass.textWhite,
                          );
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.info,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        title: Text(
                          "About App",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).dividerColor,
                        ),
                        onTap: () {
                          Get.snackbar(
                            "App Info",
                            "Task Mate v1.0.0",
                            backgroundColor: Theme.of(context).primaryColor,
                            colorText: ThemeClass.textWhite,
                          );
                        },
                      ),
                      Card(
                        color: Theme.of(context).cardColor,
                        margin: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.1),
                            width: 1.2,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Appearance",
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Obx(
                                        () => Icon(
                                          themeController.isDarkMode.value
                                              ? Icons.dark_mode
                                              : Icons.light_mode,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        "Dark Mode",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                  Obx(
                                    () => Switch(
                                      value: themeController.isDarkMode.value,
                                      onChanged: (value) {
                                        themeController.toggleTheme();
                                      },
                                      activeColor: ThemeClass.textWhite,
                                      activeTrackColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                      inactiveThumbColor: Theme.of(
                                        context,
                                      ).disabledColor,
                                      inactiveTrackColor: Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(height: 30.h),
                              Text(
                                "Security",
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                              SizedBox(height: 16.h),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.lock,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: Text(
                                  _savedPin == null
                                      ? "Set App Lock PIN"
                                      : "Change App Lock PIN",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(context).dividerColor,
                                ),
                                onTap: _showSetPinBottomSheet,
                              ),
                              Divider(height: 30.h),
                              Text(
                                "General",
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                              SizedBox(height: 16.h),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.notifications_active,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: Text(
                                  "Notifications",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(context).dividerColor,
                                ),
                                onTap: () {
                                  Get.snackbar(
                                    "Info",
                                    "Notifications setting coming soon!",
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    colorText: ThemeClass.textWhite,
                                  );
                                },
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.info,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: Text(
                                  "About App",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(context).dividerColor,
                                ),
                                onTap: () {
                                  Get.snackbar(
                                    "App Info",
                                    "Task Mate v1.0.0",
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    colorText: ThemeClass.textWhite,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

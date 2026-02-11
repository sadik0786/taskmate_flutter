import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/user/user_controller.dart';
import 'package:task_mate/model/user_request_model.dart';
import 'package:task_mate/screens/no_data.dart';
import 'package:task_mate/screens/page_loader.dart';

class AllEmployee extends StatelessWidget {
  const AllEmployee({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.put(UserController());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Obx(() {
        // Show loading for entire page
        if (userController.isLoading.value) {
          return Center(child: PageLoader());
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text("All Employees", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8.h),
            Expanded(
              child: userController.allEmployee.isEmpty
                  ? NoTasksWidget(message: "No Employee Found")
                  : ListView.builder(
                      itemCount: userController.allEmployee.length,
                      itemBuilder: (context, index) {
                        final employee = userController.allEmployee[index];
                        print("hellow ${employee}");
                        return _leaveCard(employee);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _leaveCard(UserRequestModel emp) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 15.w,
                children: [
                  Text(
                    emp.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    emp.email,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncc/view/screens/goods_inward.dart';
import 'package:ncc/view/screens/goods_outward.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'form.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late double height;
  late double width;

  Future<void> logout() async {
    try {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Clear all stored credentials
      await prefs.remove('serverIp');
      await prefs.remove('port');
      await prefs.remove('username');

      // Show success message
      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate back to login form
      Get.offAll(() => const FormIp());
    } catch (e) {
      // Show error message if logout fails
      Get.snackbar(
        'Error',
        'Failed to logout: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;
        if (width <= 1000) {
          return _smallBuildLayout();
        } else {
          return const Text("Please make sure your device is in portrait view");
        }
      },
    );
  }

  Widget _smallBuildLayout() {
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 50.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/ncc.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: logout,
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: Colors.red.shade600,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),

              // Title
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tracking",
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    Text(
                      "Your Inward & Outward Goods 📦",
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // Cards Grid
              Expanded(
                child: Column(
                  children: [
                    // First Row
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Get.to(const GoodsInward()),
                            child: Container(
                              height: height * 0.18,
                              margin: EdgeInsets.only(right: 8.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.shade600,
                                    Colors.blue.shade500,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 16.h,
                                    right: 16.w,
                                    child: Icon(
                                      Icons.input_rounded,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 28.sp,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16.h,
                                    left: 16.w,
                                    child: Text(
                                      "Gate\nInwards",
                                      style: GoogleFonts.inter(
                                        textStyle: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Get.to(const GoodsOutward()),
                            child: Container(
                              height: height * 0.18,
                              margin: EdgeInsets.only(left: 8.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.green.shade600,
                                    Colors.green.shade500,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 16.h,
                                    right: 16.w,
                                    child: Icon(
                                      Icons.output_rounded,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 28.sp,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16.h,
                                    left: 16.w,
                                    child: Text(
                                      "Gate\nOutwards",
                                      style: GoogleFonts.inter(
                                        textStyle: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
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

                    SizedBox(height: 16.h),

                    // Second Row
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: GestureDetector(
                    //         onTap: () => Get.to(Reports()),
                    //         child: Container(
                    //           height: height * 0.18,
                    //           margin: EdgeInsets.only(right: 8.w),
                    //           decoration: BoxDecoration(
                    //             gradient: LinearGradient(
                    //               begin: Alignment.topLeft,
                    //               end: Alignment.bottomRight,
                    //               colors: [
                    //                 Colors.purple.shade600,
                    //                 Colors.purple.shade500,
                    //               ],
                    //             ),
                    //             borderRadius: BorderRadius.circular(20.r),
                    //             boxShadow: [
                    //               BoxShadow(
                    //                 color: Colors.purple.withOpacity(0.3),
                    //                 blurRadius: 12,
                    //                 offset: const Offset(0, 6),
                    //               ),
                    //             ],
                    //           ),
                    //           child: Stack(
                    //             children: [
                    //               Positioned(
                    //                 top: 16.h,
                    //                 right: 16.w,
                    //                 child: Icon(
                    //                   Icons.analytics_rounded,
                    //                   color: Colors.white.withOpacity(0.8),
                    //                   size: 28.sp,
                    //                 ),
                    //               ),
                    //               Positioned(
                    //                 bottom: 16.h,
                    //                 left: 16.w,
                    //                 child: Text(
                    //                   "GateIn\nReports",
                    //                   style: GoogleFonts.inter(
                    //                     textStyle: TextStyle(
                    //                       fontSize: 18.sp,
                    //                       fontWeight: FontWeight.w600,
                    //                       color: Colors.white,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     Expanded(
                    //       child: GestureDetector(
                    //         onTap: () => Get.to(const ReportsOut()),
                    //         child: Container(
                    //           height: height * 0.18,
                    //           margin: EdgeInsets.only(left: 8.w),
                    //           decoration: BoxDecoration(
                    //             gradient: LinearGradient(
                    //               begin: Alignment.topLeft,
                    //               end: Alignment.bottomRight,
                    //               colors: [
                    //                 Colors.orange.shade600,
                    //                 Colors.orange.shade500,
                    //               ],
                    //             ),
                    //             borderRadius: BorderRadius.circular(20.r),
                    //             boxShadow: [
                    //               BoxShadow(
                    //                 color: Colors.orange.withOpacity(0.3),
                    //                 blurRadius: 12,
                    //                 offset: const Offset(0, 6),
                    //               ),
                    //             ],
                    //           ),
                    //           child: Stack(
                    //             children: [
                    //               Positioned(
                    //                 top: 16.h,
                    //                 right: 16.w,
                    //                 child: Icon(
                    //                   Icons.assessment_rounded,
                    //                   color: Colors.white.withOpacity(0.8),
                    //                   size: 28.sp,
                    //                 ),
                    //               ),
                    //               Positioned(
                    //                 bottom: 16.h,
                    //                 left: 16.w,
                    //                 child: Text(
                    //                   "GateOut\nReports",
                    //                   style: GoogleFonts.inter(
                    //                     textStyle: TextStyle(
                    //                       fontSize: 18.sp,
                    //                       fontWeight: FontWeight.w600,
                    //                       color: Colors.white,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

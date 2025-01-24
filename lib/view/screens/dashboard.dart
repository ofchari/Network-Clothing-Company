import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncc/view/screens/goods_inward.dart';
import 'package:ncc/view/screens/goods_outward.dart';
import 'package:ncc/view/screens/reports.dart';
import 'package:ncc/view/screens/reportsout.dart';
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
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      if(width<=1000){
        return _smallBuildLayout();
      }
      else{
        return const Text("Please make sure your device is in portrait view");
      }
    },);
  }
  Widget _smallBuildLayout(){
      /// Define Sizes //
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      body: SizedBox(
        width: width.w,
        child: Column(
          children: [
            SizedBox(height: 60.h,),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 50.w,),
                Padding(
                  padding:  const EdgeInsets.only(left: 12.0,right: 12.0),
                  child: Container(
                    height: height/12.1.h,
                    width: width/3.w,
                    decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage("assets/ncc.png"),fit: BoxFit.cover)
                    ),
                  ),
                ),
                Padding(
                  padding:  const EdgeInsets.only(left: 12.0,right: 12.0),
                  child: GestureDetector(
                      onTap: (){
                        logout();
                      },
                      child: const Icon(Icons.logout,color: Colors.red,size: 30,)),
                ),
              ],
            ),
            SizedBox(height: 30.h,),
            Align(
              alignment: Alignment.topLeft,
                child: Text(" Tracking",style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 55.sp,fontWeight: FontWeight.w600,color: Colors.black)),)),
            Align(
              alignment: Alignment.topLeft,
                child: Text("  Your Inward \n  & Outward \n  Goods 🛒...",style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 39.sp,fontWeight: FontWeight.w600,color: Colors.grey.shade600)),)),
            SizedBox(height: 20.h,),
            Padding(
              padding:  const EdgeInsets.only(right: 11.0,left: 11.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      Get.to(const GoodsInward());
                    },
                    child: Container(
                      height: height/4.7.h,
                      width: width/2.15.w,
                      decoration: BoxDecoration(
                          color: Colors.brown.shade400,
                          borderRadius: BorderRadius.circular(30.r)
                      ),
                      child: Center(child: Text("Gate \n Inwards",style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 23.sp,fontWeight: FontWeight.w500,color: Colors.white)),)),
                    ),
                  ),
                  SizedBox(width: 5.w,),
                  GestureDetector(
                    onTap: (){
                      Get.to(const GoodsOutward());
                    },
                    child: Container(
                      height: height/4.7.h,
                      width: width/2.15.w,
                      decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(30.r)
                      ),
                      child: Center(child: Text("Gate \n Outwards",style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 23.sp,fontWeight: FontWeight.w500,color: Colors.black)),)),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 5.h,),
            Padding(
              padding:  const EdgeInsets.only(right: 11.0,left: 11.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      Get.to(const Reports());
                    },
                    child: Container(
                      height: height/4.7.h,
                      width: width/2.15.w,
                      decoration: BoxDecoration(
                          color: Colors.brown.shade400,
                          borderRadius: BorderRadius.circular(30.r)
                      ),
                      child: Center(child: Text("GateIn \n Reports",style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 23.sp,fontWeight: FontWeight.w500,color: Colors.white)),)),
                    ),
                  ),
                  SizedBox(width: 5.w,),
                  GestureDetector(
                    onTap: (){
                      Get.to(const ReportsOut());
                    },
                    child: Container(
                      height: height/4.7.h,
                      width: width/2.15.w,
                      decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(30.r)
                      ),
                      child: Center(child: Text("GateOut \n Reports",style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 23.sp,fontWeight: FontWeight.w500,color: Colors.black)),)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

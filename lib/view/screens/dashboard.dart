import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncc/view/screens/goods_inward.dart';
import 'package:ncc/view/screens/goods_outward.dart';
import 'package:ncc/view/screens/reports.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late double height;
  late double width;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      if(width<=450){
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
            Container(
              height: height/12.1.h,
              width: width/3.w,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/ncc.png"),fit: BoxFit.cover)
              ),
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
                      child: Center(child: Text("Goods \n Inwards",style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 23.sp,fontWeight: FontWeight.w500,color: Colors.white)),)),
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
                      child: Center(child: Text("Goods \n Outwards",style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 23.sp,fontWeight: FontWeight.w500,color: Colors.black)),)),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 5.h,),
            GestureDetector(
              onTap: (){
                Get.to(Reports());
              },
              child: Container(
                height: height/7.h,
                width: width/1.09.w,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30.r)
                ),
                child: Center(child: Text("Reports",style: GoogleFonts.outfit(textStyle: TextStyle(fontSize: 24.3.sp,fontWeight: FontWeight.w500,color: Colors.white)),)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

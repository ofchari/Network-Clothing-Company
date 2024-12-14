import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ncc/view/widgets/buttons.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:ncc/view/widgets/text.dart';

class GoodsOutward extends StatefulWidget {
  const GoodsOutward({super.key});

  @override
  State<GoodsOutward> createState() => _GoodsOutwardState();
}

class _GoodsOutwardState extends State<GoodsOutward> {
  late double height;
  late double width;
  final _dateController = TextEditingController();
  // DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      if(width<=450){
        return _smallBuildLayout();
      }
      else{
        return const Text("Please Make sure Your device is in portrait view");
      }
    },);
  }
  Widget _smallBuildLayout(){
    /// Define Sizes //
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      backgroundColor: const Color(0xfff1f2f4),
      appBar: AppBar(
        // leading: GestureDetector(
        //     onTap: (){
        //       Get.back();
        //     },
        //     child: Icon(Icons.arrow_back_ios,color: Colors.black,)),
        title: const Subhead(text: "Goods Outward", weight: FontWeight.w500, color: Colors.black,),
        centerTitle: true,
        toolbarHeight: 70.h,
        backgroundColor: const Color(0xfff1f2f4),
      ),
      body: SizedBox(
        width: width.w,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10.h,),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "     Exporter :", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 5.h,),
              Container(
                height: height/15.h,
                width: width/1.09.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6.r)
                ),
                child: TextFormField(
                  readOnly: true,
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "NETWORK CLOTHING COMPANY PRIVATED LIMITED",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon: const Icon(
                        Icons.home_work_outlined,
                        color: Colors.black,
                        size: 16,
                      ),
                      border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 13.h,),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "     Gate Doc No ", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 7.5.h,),
              Container(
                height: height/15.h,
                width: width/1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(
                      color: Colors.grey.shade500,
                    ),
                    borderRadius: BorderRadius.circular(6.r)
                ),
                child: TextFormField(
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon:  Icon(
                        Icons.now_wallpaper_rounded,
                        color: Colors.grey.shade700,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 13.h,),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "    Dc No ", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 7.5.h,),
              Container(
                height: height/15.h,
                width: width/1.13.w,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey.shade500
                    ),
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6.r)
                ),
                child: TextFormField(
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon: const Icon(
                        Icons.dashboard_customize_rounded,
                        color: Colors.black,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 13.h,),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "     Time", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 7.5.h,),
              Container(
                height: height/15.h,
                width: width/1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(
                        color: Colors.grey.shade500
                    ),
                    borderRadius: BorderRadius.circular(6.r)
                ),
                child: TextFormField(
                  // onTap: (){
                  //   formattedDate;
                  // },
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: formattedDate,
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon: const Icon(
                        Icons.alarm,
                        color: Colors.black,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 13.h,),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "     Party ", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 7.5.h,),
              Container(
                height: height/15.h,
                width: width/1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(
                        color: Colors.grey.shade500
                    ),
                    borderRadius: BorderRadius.circular(6.r)
                ),
                child: TextFormField(
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      prefixIcon: const Icon(
                        Icons.data_exploration_outlined,
                        color: Colors.black,
                        size: 17.5,
                      ),
                      border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 13.h,),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "     Delqty ", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 7.5.h,),
              Container(
                height: height/15.h,
                width: width/1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(
                        color: Colors.grey.shade500
                    ),
                    borderRadius: BorderRadius.circular(6.r)
                ),
                child: TextFormField(
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon: const Icon(
                        Icons.delete,
                        color: Colors.black,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 15.h,),
              Buttons(height: height/18.h, width: width/2, radius: BorderRadius.circular(7), color: Colors.blue, text: "Submit"),
              SizedBox(height: 15.h,),

            ],
          ),
        ),
      ),
    );
  }
}



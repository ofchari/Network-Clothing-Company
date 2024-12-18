import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ncc/view/widgets/buttons.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:ncc/view/widgets/text.dart';

import 'dashboard.dart';

class GoodsInward extends StatefulWidget {
  const GoodsInward({super.key});

  @override
  State<GoodsInward> createState() => _GoodsInwardState();
}

class _GoodsInwardState extends State<GoodsInward> {
  late double height;
  late double width;
  final _dateController = TextEditingController();
  // DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  // Get the current date and time
  DateTime now = DateTime.now();

// Convert to ISO 8601 string (common format for APIs)
  String currentTime = DateTime.now().toIso8601String();

  // print(currentTime) // Output: e.g., 2024-12-18T14:35:20.123Z

  /// Controller for post method //
  final exports = TextEditingController();
  final docid = TextEditingController();
  final podc = TextEditingController();
  final gst = TextEditingController();
  final type = TextEditingController();
  final party = TextEditingController();
  final dc = TextEditingController();
  final date = TextEditingController();
  final qtys = TextEditingController();

                  /// Post method for Goods Inward //
  /// Post method for Goods Inward //
  Future<void> MobileDocument(BuildContext context) async {
    // Allow self-signed certificates for development purposes
    HttpClient client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    // API endpoint
    const String url = 'http://192.168.1.7:8080/db/dbconnect.php';

    // HTTP headers
    final headers = {
      'Content-Type': 'application/json',
    };

    // Set up the data for the API request
    final data = {
      "Exporter": "NETWORK CLOTHING COMPANY PRIVATED LIMITED",
      "DocId": docid.text,
      "PoDcNo": podc.text,
      "GstNo": gst.text,
      "Type": type.text,
      "PartyName": party.text,
      "DcNoAndDate": "${dc.text}, ${_dateController.text}",
      "Time": currentTime,
      "GrnQty": 200
    };

    print('Request Data: $data');

    try {
      // Make the API call
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );

      // Handle success
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      }
      // Handle server-side validation errors
      else if (response.statusCode == 417) {
        final responseJson = json.decode(response.body);
        final serverMessages = responseJson['_server_messages'] ?? 'No server messages found';

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Message'),
            content: SingleChildScrollView(
              child: Text(serverMessages),
            ),
            actions: [
              ElevatedButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );

        print('Server Messages: $serverMessages');
      }
      // Handle other errors
      else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Request failed with status: ${response.statusCode}'),
            actions: [
              ElevatedButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );

        print('Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (error) {
      // Handle exceptions like network issues
      print('Exception: $error');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An unexpected error occurred: $error'),
          actions: [
            ElevatedButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

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
        //   onTap: (){
        //     Get.back();
        //   },
        //     child: Icon(Icons.arrow_back_ios,color: Colors.black,)),
        title: const Subhead(text: "Goods Inward", weight: FontWeight.w500, color: Colors.black,),
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
                height: height/15.2.h,
                width: width/1.09.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6.r)
                ),
                child: TextFormField(
                  controller: exports,
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
                  child: MyText(text: "     Docid ", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 7.5.h,),
              Container(
                height: height/15.2.h,
                width: width/1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(
                      color: Colors.grey.shade500,
                    ),
                    borderRadius: BorderRadius.circular(6.r)
                ),
                child: TextFormField(
                  controller: docid,
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon:  Icon(
                        Icons.fact_check,
                        color: Colors.grey.shade700,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 14.5.h,),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "     Po/Dc No ", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 7.5.h,),
              Container(
                height: height/15.2.h,
                width: width/1.13.w,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey.shade500
                    ),
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6.r)
                ),
                child: TextFormField(
                  controller: podc,
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon:  Icon(
                        Icons.pattern,
                        color: Colors.grey.shade700,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 14.5..h,),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "     GST No ", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 7.5.h,),
              Container(
                height: height/15.2.h,
                width: width/1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(
                        color: Colors.grey.shade500
                    ),
                    borderRadius: BorderRadius.circular(6.r)
                ),
                child: TextFormField(
                  controller: gst,
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon:  Icon(
                        Icons.security_update_good_rounded,
                        color: Colors.grey.shade700,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 14.5..h,),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "     Type ", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 7.5.h,),
              Container(
                height: height/15.2.h,
                width: width/1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(
                        color: Colors.grey.shade500
                    ),
                    borderRadius: BorderRadius.circular(6.r)
                ),
                child: TextFormField(
                  controller: type,
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon:  Icon(
                        Icons.merge_type,
                        color: Colors.grey.shade700,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 14.5..h,),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "     Party Name ", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 7.5.h,),
              Container(
                height: height/15.2.h,
                width: width/1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(
                        color: Colors.grey.shade500
                    ),
                    borderRadius: BorderRadius.circular(6.r)
                ),
                child: TextFormField(
                  controller: party,
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      prefixIcon: Icon(
                        Icons.data_exploration_outlined,
                        color: Colors.grey.shade700,
                        size: 17.5,
                      ),
                      border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 14.5..h,),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "      DC No/Dt", weight: FontWeight.w500, color: Colors.black)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: height/15.2.h,
                      width: width/2.2.w,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: Colors.grey.shade500
                          ),
                          borderRadius: BorderRadius.circular(6.r)
                      ),
                      child: TextFormField(
                        controller: dc,
                        style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                        decoration: InputDecoration(
                            labelText: "",
                            labelStyle: GoogleFonts.sora(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            prefixIcon:  Icon(
                              Icons.data_exploration_outlined,
                              color: Colors.grey.shade700,
                              size: 17.5,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                            border: InputBorder.none
                        ),
                      ),
                    ),
                    Container(
                      height: height/15.2.h,
                      width: width/2.2.w,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: Colors.grey.shade500
                          ),
                          borderRadius: BorderRadius.circular(6.r)
                      ),
                      child: TextFormField(
                        controller: _dateController,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                            }
                          },
                        style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                        decoration: InputDecoration(
                            labelText: "Date",
                            labelStyle: GoogleFonts.sora(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            prefixIcon:  Icon(
                              Icons.date_range,
                              color: Colors.grey.shade700,
                              size: 17.5,
                            ),
                            border: InputBorder.none
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.5..h,),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "     Time", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 7.5.h,),
              Container(
                height: height/15.2.h,
                width: width/1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(
                        color: Colors.grey.shade500
                    ),
                    borderRadius: BorderRadius.circular(6.r)
                ),
                child: TextFormField(
                  readOnly: true,
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: formattedDate,
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon:  Icon(
                        Icons.alarm,
                        color: Colors.grey.shade700,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 15.h,),
              GestureDetector(
                onTap: (){
                  MobileDocument(context);
                },
                  child: Buttons(height: height/18.h, width: width/2, radius: BorderRadius.circular(7), color: Colors.blue, text: "Submit")),
              SizedBox(height: 15.h,),
            ],
          ),
        ),
      ),
    );
  }
}



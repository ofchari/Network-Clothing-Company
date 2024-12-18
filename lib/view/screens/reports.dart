import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:ncc/view/widgets/text.dart';
import '../../model/json_model/Outward_get_json.dart';
import '../../services/goods_Outward_api.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  late double height;
  late double width;

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for scaling
    ScreenUtil.init(context);

    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;

        if (width <= 450) {
          return _smallBuildLayout();
        } else {
          return Text("Please Make sure your device is in portrait view");
        }
      },
    );
  }

  Widget _smallBuildLayout() {
    return Scaffold(
      appBar: AppBar(
        title: MyText(text: "Reports", weight: FontWeight.w500, color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SizedBox(
        width: ScreenUtil().setWidth(width),
        child: Column(
          children: [
            FutureBuilder(
                future: fetchOutward(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("${snapshot.error}"));
                  } else {
                    return Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,  // Add horizontal scrolling
                            child: DataTable(
                              headingRowHeight: 56.0,
                              columnSpacing: 16.0,
                              columns: const [
                                DataColumn(label: MyText(text: 'Exporter', weight: FontWeight.w500, color: Colors.black,)),
                                DataColumn(label: MyText(text: 'Doc ID', weight: FontWeight.w500, color: Colors.black,)),
                                DataColumn(label: MyText( text: 'POD CNo', weight: FontWeight.w500, color: Colors.black,)),
                                DataColumn(label: MyText(text: "GSTNo", weight: FontWeight.w500, color: Colors.black)),
                                DataColumn(label: MyText(text: "Type", weight: FontWeight.w500, color: Colors.black)),
                                DataColumn(label: MyText(text: "Party Name", weight: FontWeight.w500, color: Colors.black)),
                                DataColumn(label: MyText(text: "Dc No and Date", weight: FontWeight.w500, color: Colors.black)),
                              ],
                              rows: snapshot.data!.map<DataRow>((outs) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(outs.exporter.toString(),style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)),)),
                                    DataCell(Text(outs.docid.toString(),style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                    DataCell(Text(outs.podcno.toString(),style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                    DataCell(Text(outs.gstno.toString(),style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                    DataCell(Text(outs.type.toString(),style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                    DataCell(Text(outs.partyname.toString(),style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                    DataCell(Text(outs.dcnoanddate.toString(),style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}

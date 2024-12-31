import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncc/services/goods_outward_api.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:ncc/view/widgets/text.dart';
import '../../model/json_model/outward_get_json.dart';
import '../../services/goods_Inward_api.dart';

class ReportsOut extends StatefulWidget {
  const ReportsOut({super.key});

  @override
  State<ReportsOut> createState() => _ReportsOutState();
}

class _ReportsOutState extends State<ReportsOut> {
  late double height;
  late double width;

  @override
  Widget build(BuildContext context) {
    /// Define Sizes //
    var size = MediaQuery.of(context).size;
    height = size.height.h;
    width = size.width.w;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;

        if (width <= 450) {
          return _smallBuildLayout();
        } else {
          return const Text("Please Make sure your device is in portrait view");
        }
      },
    );
  }

  Widget _smallBuildLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Subhead(text: "GateOut Reports", weight: FontWeight.w500, color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SizedBox(
        width: width.w,
        child: Column(
          children: [
            FutureBuilder<List<Datumm>>(
              future: fetchOutward(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                              DataColumn(label: MyText(text: 'GATEMASID', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'CANCEL', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'SOURCEID', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'MAPNAME', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'USERNAME', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'MODIFIEDON', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'CREATEDBY', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'CREATEDON', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'WKID', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'APP_LEVEL', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'APP_DESC', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'APP_SLEVEL', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'CANCELREMARKS', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'WFROLES', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DOCDATE', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DCNO', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'STIME', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'PARTY', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DELQTY', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'JOBCLOSE', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'STMUSER', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'REMARKS', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'JJFORMNO', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DCNOS', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'ATIME', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'ITIME', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'FINYEAR', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DCDATE', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'RECID', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'ENAME', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'USERID', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DOCDATE', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DOCMAXNO', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DPREFIX', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DOCID', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'USCODE', weight: FontWeight.w500, color: Colors.black)),



                            ],
                            rows: snapshot.data!.map<DataRow>((gateOut) {
                              // print("gATEINMASID: ${outs.gATEINMASID}");
                              // print("cANCEL: ${outs.cANCEL}");
                              // print("sOURCEID: ${outs.sOURCEID}");
                              // print("mAPNAME: ${outs.mAPNAME}");
                              // print("uSERNAME: ${outs.uSERNAME}");
                              // print("mODIFIEDON: ${outs.mODIFIEDON}");
                              // print("cREATEDBY: ${outs.cREATEDBY}");
                              // print("cREATEDON: ${outs.cREATEDON}");
                              // print("wKID: ${outs.wKID}");
                              // print("aPPLEVEL: ${outs.aPPLEVEL}");
                              // print("aPPDESC: ${outs.aPPDESC}");
                              // print("aPPSLEVEL: ${outs.aPPSLEVEL}");
                              // print("cANCELREMARKS: ${outs.cANCELREMARKS}");
                              // print("wFROLES: ${outs.wFROLES}");
                              // print("dOCDATE: ${outs.dOCDATE}");

                              return DataRow(
                                cells: [
                                  DataCell(Text(gateOut.GATEMASID.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.CANCEL.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.SOURCEID.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.MAPNAME.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.USERNAME.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.MODIFIEDON.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.CREATEDBY.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.CREATEDON.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.WKID.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.APP_LEVEL.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.APP_DESC.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.APP_SLEVEL.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.CANCELREMARKS.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.WFROLES.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.DOCDATE.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(gateOut.DCNO.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.STIME.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.PARTY.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.DELQTY.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.JOBCLOSE.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.STMUSER.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.REMARKS.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.JJFORMNO.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.DCNOS.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.ATIME.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.ITIME.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.FINYEAR.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.DCDATE.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.RECID.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.ENAME.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.USERID.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.DOCDATE.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.DOCMAXNO.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.DPREFIX.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.DOCID.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(gateOut.USCODE.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),

                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

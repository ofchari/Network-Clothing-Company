import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:ncc/view/widgets/text.dart';
import '../../services/goods_Inward_api.dart';

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
        title: const Subhead(text: "GateIn Reports", weight: FontWeight.w500, color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SizedBox(
        width: width.w,
        child: Column(
          children: [
            FutureBuilder(
              future: fetchInward(),
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
                              DataColumn(label: MyText(text: 'Gatein MASID', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Cancel', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Source ID', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Map Name', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Username', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Modified On', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Created By', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Created On', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'WKID', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'App Level', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'App Desc', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'AppS Level', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Cancel Remarks', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'WF Roles', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Doc Date', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Del Ctrl', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Dept', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DC No', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'STime', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Party', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Del Qty', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Dup Check', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Job Close', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'STM User', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Remarks', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'EName', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DC Date', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DINW No', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DINW On', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DINW By', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'To Dept', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'ATime', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'ITime', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Fin Year', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DocID1', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'SUpplier', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Job Closed By', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'JClosed On', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'UserID', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'NParty', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'PODC Check', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'GST', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'GSTYN', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'PODC', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'RecID', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Doc Max No', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DPrefix', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Doc 1', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DocID Old', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'User Code', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'DelReq', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Party1', weight: FontWeight.w500, color: Colors.black)),
                              DataColumn(label: MyText(text: 'Dup Check1', weight: FontWeight.w500, color: Colors.black)),
                            ],
                            rows: snapshot.data!.map<DataRow>((outs) {
                              print("gATEINMASID: ${outs.gATEINMASID}");
                              print("cANCEL: ${outs.cANCEL}");
                              print("sOURCEID: ${outs.sOURCEID}");
                              print("mAPNAME: ${outs.mAPNAME}");
                              print("uSERNAME: ${outs.uSERNAME}");
                              print("mODIFIEDON: ${outs.mODIFIEDON}");
                              print("cREATEDBY: ${outs.cREATEDBY}");
                              print("cREATEDON: ${outs.cREATEDON}");
                              print("wKID: ${outs.wKID}");
                              print("aPPLEVEL: ${outs.aPPLEVEL}");
                              print("aPPDESC: ${outs.aPPDESC}");
                              print("aPPSLEVEL: ${outs.aPPSLEVEL}");
                              print("cANCELREMARKS: ${outs.cANCELREMARKS}");
                              print("wFROLES: ${outs.wFROLES}");
                              print("dOCDATE: ${outs.dOCDATE}");

                              return DataRow(
                                cells: [
                                  DataCell(Text(outs.gATEINMASID.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.cANCEL.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.sOURCEID.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.mAPNAME.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.uSERNAME.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.mODIFIEDON.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.cREATEDBY.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.cREATEDON.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.wKID.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.aPPLEVEL.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.aPPDESC.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.aPPSLEVEL.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.cANCELREMARKS.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.wFROLES.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.dOCDATE.toString(),overflow: TextOverflow.ellipsis,   style: GoogleFonts.figtree(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                                  DataCell(Text(outs.dELCTRL.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dEPT.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dCNO.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.sTIME.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.pARTY.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dELQTY.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dUPCHK.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.jOBCLOSE.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.sTMUSER.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.rEMARKS.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.eNAME.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dCDATE.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dINWNO.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dINWON.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dINWBY.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.tODEPT.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.aTIME.toString(),overflow: TextOverflow.ellipsis,  style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.iTIME.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.fINYEAR.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dOCID.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.sUPP.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.jOBCLOSEDBY.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.jCLOSEDON.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.uSERID.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.nPARTY.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.pODCCHK.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.gST.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.gSTYN.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.pODC.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.rECID.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dOCMAXNO.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dPREFIX.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dOCID1.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.uSCODE.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dELREQ.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dOCIDOLD.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.pARTY1.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                                  DataCell(Text(outs.dUPCHK1.toString(),overflow: TextOverflow.ellipsis, style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
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

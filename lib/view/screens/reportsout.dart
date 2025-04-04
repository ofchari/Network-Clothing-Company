import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncc/services/goods_outward_api.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:ncc/view/widgets/text.dart';
import '../../model/json_model/outward_get_json.dart';

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

        if (width <= 1000) {
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
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data available"));
          } else {
            return Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 56.0,
                      columnSpacing: 16.0,
                      columns: const [
                        DataColumn(label: MyText(text: 'DOCID', weight: FontWeight.w500, color: Colors.black)),
                        DataColumn(label: MyText(text: 'DOCDATE', weight: FontWeight.w500, color: Colors.black)),
                        DataColumn(label: MyText(text: 'DCNO', weight: FontWeight.w500, color: Colors.black)),
                        DataColumn(label: MyText(text: 'DCDATE', weight: FontWeight.w500, color: Colors.black)),
                        DataColumn(label: MyText(text: 'PARTY', weight: FontWeight.w500, color: Colors.black)),
                        DataColumn(label: MyText(text: 'DELQTY', weight: FontWeight.w500, color: Colors.black)),
                        DataColumn(label: MyText(text: 'STMUSER', weight: FontWeight.w500, color: Colors.black)),
                        DataColumn(label: MyText(text: 'ITIME', weight: FontWeight.w500, color: Colors.black)),
                      ],
                      rows: snapshot.data!.map<DataRow>((gateOut) {
                        return DataRow(
                          cells: [
                            DataCell(Text(gateOut.DOCID ?? "-", overflow: TextOverflow.ellipsis)),
                            DataCell(Text(gateOut.DOCDATE?.split('T')[0] ?? "-", overflow: TextOverflow.ellipsis)),
                            DataCell(Text(gateOut.DCNO ?? "-", overflow: TextOverflow.ellipsis)),
                            DataCell(Text(gateOut.DCDATE?.split('T')[0] ?? "-", overflow: TextOverflow.ellipsis)),
                            DataCell(Text(gateOut.PARTY ?? "-", overflow: TextOverflow.ellipsis)),
                            DataCell(Text(gateOut.DELQTY?.toString() ?? "-", overflow: TextOverflow.ellipsis)),
                            DataCell(Text(gateOut.STMUSER ?? "-", overflow: TextOverflow.ellipsis)),
                            DataCell(Text(gateOut.STIME ?? "-", overflow: TextOverflow.ellipsis)),
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

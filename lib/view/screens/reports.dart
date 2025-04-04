import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ncc/view/widgets/subhead.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Reports extends StatefulWidget {
  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  late Future<List<Data>> inwardData;

  @override
  void initState() {
    super.initState();
    inwardData = fetchInward();
  }

  Future<List<Data>> fetchInward() async {
    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('port') ?? '';
    final username = prefs.getString('username') ?? '';

    if (serverIp.isEmpty || port.isEmpty) {
      throw Exception("Server IP or Port not set");
    }

    final apiUrl = "http://$serverIp:$port/get_api?username=$username";
    final response = await http.get(Uri.parse(apiUrl));
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      List<dynamic> outwards = jsonDecode(response.body);
      return outwards.map((e) => Data.fromJson(e)).toList();
    } else {
      throw Exception("Error status ${response.statusCode}");
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Subhead(text: "GateIn Reports", weight: FontWeight.w500, color: Colors.white),
        centerTitle: true
        ,
      ),
      body: FutureBuilder<List<Data>>(
        future: inwardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No data available"));
          }

          // Debugging: Print the received data
          print("Fetched Data: ${snapshot.data}");
          // print("DELQTY type: ${json['DELQTY'].runtimeType}");
          // print("DELQTY value: ${data['DELQTY']}");


          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('DOCID')),
                  DataColumn(label: Text('DOCDATE')),
                  DataColumn(label: Text('DEPT')),
                  DataColumn(label: Text('DCNO')),
                  DataColumn(label: Text('DCDATE')),
                  DataColumn(label: Text('STIME')),
                  DataColumn(label: Text('PARTYID')),
                  DataColumn(label: Text('DELQTY')),
                  DataColumn(label: Text('STMUSER')),
                  DataColumn(label: Text('PODC')),
                  DataColumn(label: Text('GST')),
                ],
                rows: snapshot.data!.map((data) {
                  print(data.DELQTY.runtimeType);
                  // print("DELQTY type: ${json['DELQTY'].runtimeType}");
                  return DataRow(cells: [
                    DataCell(Text(data.DOCID ?? '-')),
                    DataCell(Text(data.DOCDATE.split('T')[0] ?? "-", overflow: TextOverflow.ellipsis)),
                    DataCell(Text(data.DEPT ?? '-')),
                    DataCell(Text(data.DCNO ?? '-')),
                    DataCell(Text(data.DCDATE.split('T')[0] ?? "-", overflow: TextOverflow.ellipsis)),
                    DataCell(Text(data.STIME ?? '-')),
                    DataCell(Text(data.PARTYID ?? '-')),
                    DataCell(Text(data.DELQTY.toString() ?? '-')),
                    DataCell(Text(data.STMUSER ?? '-')),
                    DataCell(Text(data.PODC ?? '-')),
                    DataCell(Text(data.GST ?? '-')),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

}

class Data {
  final String DOCID;
  final String DOCDATE;
  final String DEPT;
  final String? TODEPT;
  final String DCNO;
  final String DCDATE;
  final String STIME;
  final String PARTYID;
  final String DELQTY;
  final String STMUSER;
  final String PODC;
  final String GST;

  Data({
    required this.DOCID,
    required this.DOCDATE,
    required this.DEPT,
    this.TODEPT,
    required this.DCNO,
    required this.DCDATE,
    required this.STIME,
    required this.PARTYID,
    required this.DELQTY,
    required this.STMUSER,
    required this.PODC,
    required this.GST,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      DOCID: json['DOCID'].toString(),
      DOCDATE: json['DOCDATE']?.toString() ?? '-',
      DEPT: json['DEPT']?.toString() ?? '-',
      TODEPT: json['TODEPT']?.toString() ?? '-',
      DCNO: json['DCNO']?.toString() ?? '-',
      DCDATE: json['DCDATE']?.toString() ?? '-',
      STIME: json['STIME']?.toString() ?? '-',
      PARTYID: json['PARTYID']?.toString() ?? '-',
      DELQTY: json['DELQTY']?.toString() ?? '0', // Convert to string
      STMUSER: json['STMUSER']?.toString() ?? '-',
      PODC: json['PODC']?.toString() ?? '-',
      GST: json['GST']?.toString() ?? '-',
    );
  }


}

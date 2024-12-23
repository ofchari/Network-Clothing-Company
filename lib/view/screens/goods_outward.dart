import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ncc/view/screens/scanner.dart';
import 'package:ncc/view/widgets/buttons.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:ncc/view/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';

class GoodsOutward extends StatefulWidget {
  const GoodsOutward({super.key});

  @override
  State<GoodsOutward> createState() => _GoodsOutwardState();
}

class _GoodsOutwardState extends State<GoodsOutward> {
  late double height;
  late double width;
  late String usCode;
  late int orderNumber;
  bool isEditable = false;
  // final _dateController = TextEditingController();
  final _dcNoController = TextEditingController();
  final _dcDateController = TextEditingController();
  final _partyController = TextEditingController();
  final _delQtyController = TextEditingController();

  String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  /// Controller for post method //
  final gateInMasId = TextEditingController();  // GATEINMASID
  final cancel = TextEditingController();       // CANCEL
  final sourceId = TextEditingController();     // SOURCEID
  final mapName = TextEditingController();      // MAPNAME
  final username = TextEditingController();     // USERNAME
  final modifiedOn = TextEditingController();   // MODIFIEDON
  final createdBy = TextEditingController();    // CREATEDBY
  final createdOn = TextEditingController();    // CREATEDON
  final wkId = TextEditingController();         // WKID
  final appLevel = TextEditingController();     // APP_LEVEL
  final appDesc = TextEditingController();      // APP_DESC
  final appSLevel = TextEditingController();    // APP_SLEVEL
  final cancelRemarks = TextEditingController(); // CANCELREMARKS
  final wfRoles = TextEditingController();      // WFROLES
  final docDate = TextEditingController();      // DOCDATE
  final delCtrl = TextEditingController();      // DELCTRL
  final dept = TextEditingController();         // DEPT
  final dcNo = TextEditingController();         // DCNO
  final stime = TextEditingController();        // STIME
  // final party = TextEditingController();        // PARTY
  final delQty = TextEditingController();       // DELQTY
  final dupChk = TextEditingController();       // DUPCHK
  final jobClose = TextEditingController();     // JOBCLOSE
  final stmUser = TextEditingController();      // STMUSER
  final remarks = TextEditingController();      // REMARKS
  final eName = TextEditingController();        // ENAME
  final dcDate = TextEditingController();       // DCDATE
  final dinWno = TextEditingController();       // DINWNO
  final dinWon = TextEditingController();       // DINWON
  final dinWby = TextEditingController();       // DINWBY
  final toDept = TextEditingController();       // TODEPT
  final aTime = TextEditingController();        // ATIME
  final iTime = TextEditingController();        // ITIME
  final finYear = TextEditingController();      // FINYEAR
  // final docId = TextEditingController();        // DOCID
  final supp = TextEditingController();         // SUPP
  final jobClosedBy = TextEditingController();  // JOBCLOSEDBY
  final jClosedOn = TextEditingController();    // JCLOSEDON
  final userId = TextEditingController();       // USERID
  final nParty = TextEditingController();       // NPARTY
  final podcChk = TextEditingController();      // PODCCHK
  // final gst = TextEditingController();          // GST
  final gstYn = TextEditingController();        // GSTYN
  final podc = TextEditingController();         // PODC
  final recId = TextEditingController();        // RECID
  final docMaxNo = TextEditingController();     // DOCMAXNO
  final dPrefix = TextEditingController();      // DPREFIX
  final docId1 = TextEditingController();       // DOCID1
  final ussCode = TextEditingController();       // USCODE
  final delReq = TextEditingController();       // DELREQ
  final docIdOld = TextEditingController();     // DOCIDOLD
  final party1 = TextEditingController();       // PARTY1
  final dupChk1 = TextEditingController();      // DUPCHK1
  final JJFORMNO = TextEditingController();      // DUPCHK1

  // Method to fetch data from API and populate fields
  Future<void> fetchAndPopulateData(String dcNo) async {
    final url = Uri.parse('http://192.168.1.8:8080/db/outwarddc_view_get_api.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final record = data.firstWhere((item) => item['DOCID'] == dcNo, orElse: () => null);
        if (record != null) {
          setState(() {
            _dcDateController.text = record['DOCDATE'] ?? '';
            _partyController.text = record['PARTYID'] ?? '';
            _delQtyController.text = record['TOTQTY']?.toString() ?? '';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No record found for DC No: $dcNo')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch data: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }
               /// Load card details ///
  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    usCode = prefs.getString('usCode') ?? 'UNKNOWN';
    orderNumber = prefs.getInt('orderNumber_$usCode') ?? 1;  // Start from 1 for the user

    setState(() {});
  }

                /// Post method for this Goods Outward //
  Future<void> MobileDocument(BuildContext context) async {
    // Allow self-signed certificates for development purposes
    HttpClient client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    // Retrieve dynamic URL from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('port') ?? '';

    if (serverIp.isEmpty || port.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Configuration Error'),
          content: const Text('Server IP and port are not configured. Please set them in the settings.'),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }
    // Increment the order number
    await prefs.setInt('orderNumber_$usCode', orderNumber + 1);

    final dcNo = "$usCode/24/I/$orderNumber";

    // Construct the dynamic API endpoint
    final String url = 'http://$serverIp:$port/db/outward_post_api.php';

    // HTTP headers
    final headers = {
      'Content-Type': 'application/json',
    };

    // Fix: Create a single Map instead of a Set containing a Map
    final data = {
      "GATEMASID": "13244000005249",
      "CANCEL": "F",
      "SOURCEID": "0",
      "MAPNAME": "",
      "USERNAME": "eagleate",
      "MODIFIEDON": "2024-12-01 12:00:00",
      "CREATEDBY": "eagleate",
      "CREATEDON": "2024-12-01 12:00:00",
      "WKID": "",
      "APP_LEVEL": "1",
      "APP_DESC": "1",
      "APP_SLEVEL": "",
      "CANCELREMARKS": "",
      "WFROLES": "",
      "DOCDATE": "2024-12-01",
      "DCNO": _dcNoController.text,
      "STIME": "12:00 PM",
      "PARTY": party1.text,  // Fix: Access the text property
      "DELQTY": "100.5",
      "JOBCLOSE": "NO",
      "STMUSER": stmUser.text,
      "REMARKS": remarks.text,
      "JJFORMNO": JJFORMNO.text,
      "DCNOS": "DcNoo",  // Fix: Access the text property
      "ATIME": formattedDate,
      "ITIME": formattedDate,
      "DCDATE": _dcDateController.text,  // Fix: Access the text property
      "RECID": recId.text,
      "ENAME": eName.text,
      "USERID": "eagleate",
      "FINYEAR": "2024-2025",
      "DOCMAXNO": docMaxNo.text,
      "DPREFIX": dPrefix.text,
      "DOCID": docId1.text,
      "USCODE": ussCode.text
    };

    print('Request Data: $data');
    print('Dynamic URL: $url');

    try {
      // Make the API call
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );

      // Rest of the error handling code remains the same...
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Show success snackbar
        Get.snackbar(
          "Success",
          "Document posted successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      } else if (response.statusCode == 417) {
        final responseJson = json.decode(response.body);
        final serverMessages = responseJson['_server_messages'] ?? 'No server messages found';

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Message'),
            content: SingleChildScrollView(
              child: Text(serverMessages),
            ),
            actions: [
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Request failed with status: ${response.statusCode}'),
            actions: [
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('Exception: $error');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An unexpected error occurred: $error'),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }


  void openMobileScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        _dcNoController.text = result; // Populate scanned value in TextFormField.
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAndPopulateData;
    _loadUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;
        if (width <= 450) {
          return _smallBuildLayout();
        } else {
          return const Text("Please Make sure Your device is in portrait view");
        }
      },
    );
  }

  Widget _smallBuildLayout() {
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      backgroundColor: const Color(0xfff1f2f4),
      appBar: AppBar(
        title: const Subhead(
          text: "Goods Outward",
          weight: FontWeight.w500,
          color: Colors.black,
        ),
        centerTitle: true,
        toolbarHeight: 70.h,
        backgroundColor: const Color(0xfff1f2f4),
      ),
      body: SizedBox(
        width: width.w,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10.h),
              const Align(
                alignment: Alignment.topLeft,
                child: MyText(
                  text: "     Exporter :",
                  weight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5.h),
              Container(
                height: height / 15.h,
                width: width / 1.09.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: TextFormField(
                  readOnly: true,
                  style: GoogleFonts.dmSans(
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
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
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: MyText(
                  text: "    Gate Dc No ",
                  weight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Container(
                height: height / 15.h,
                width: width / 1.13.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade500),
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: TextFormField(
                  // controller: _dcDateController,
                  readOnly: true,
                  style: GoogleFonts.dmSans(
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  decoration: InputDecoration(
                    labelText: "$usCode/24/I/$orderNumber",
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
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 13.h),
              const Align(
                alignment: Alignment.topLeft,
                child: MyText(
                  text: "     Dc No ",
                  weight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 7.5.h),
              // Updated TextFormField widget:
              Container(
                height: height / 15.h,
                width: width / 1.13.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(
                    color: Colors.grey.shade500,
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: TextFormField(
                  controller: _dcNoController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      fetchAndPopulateData(value);
                    }
                  },
                  style: GoogleFonts.dmSans(
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  decoration: InputDecoration(
                    labelText: "",
                    labelStyle: GoogleFonts.sora(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    prefixIcon: Icon(
                      Icons.now_wallpaper_rounded,
                      color: Colors.grey.shade700,
                      size: 17.5,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 13.h),
              const Align(
                alignment: Alignment.topLeft,
                child: MyText(
                  text: "    Dc Date ",
                  weight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 7.5.h),
              Container(
                height: height / 15.h,
                width: width / 1.13.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade500),
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: TextFormField(
                  controller: _dcDateController,
                  readOnly: true,
                  style: GoogleFonts.dmSans(
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
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
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 13.h),
              const Align(
                alignment: Alignment.topLeft,
                child: MyText(
                  text: "     Party ",
                  weight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 7.5.h),
              Container(
                height: height / 15.h,
                width: width / 1.13.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade500),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: TextFormField(
                  controller: _partyController,
                  readOnly: true,
                  style: GoogleFonts.dmSans(
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  decoration: InputDecoration(
                    labelText: "",
                    labelStyle: GoogleFonts.sora(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    prefixIcon: const Icon(
                      Icons.data_exploration_outlined,
                      color: Colors.black,
                      size: 17.5,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 13.h),
              const Align(
                alignment: Alignment.topLeft,
                child: MyText(
                  text: "     Delqty ",
                  weight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 7.5.h), // Add this variable to toggle edit mode.
              Container(
                height: height / 15.h,
                width: width / 1.13.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade500),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _delQtyController,
                        style: GoogleFonts.dmSans(
                          textStyle: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
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
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isEditable ? Icons.check : Icons.edit,
                        // Change icon based on mode.
                        color: Colors.green,
                      ),
                      onPressed: () {
                        setState(() {
                          isEditable = !isEditable; // Toggle edit mode.
                        });
                      },
                    ),
                  ],
          ),
        ),

        SizedBox(height: 15.h),
              GestureDetector(
                onTap: (){
                  MobileDocument(context);
                },
                child: Buttons(
                  height: height / 18.h,
                  width: width / 2,
                  radius: BorderRadius.circular(7),
                  color: Colors.blue,
                  text: "Submit",
                ),
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }
}


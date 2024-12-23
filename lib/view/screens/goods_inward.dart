import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ncc/view/widgets/buttons.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:ncc/view/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class GoodsInward extends StatefulWidget {
  const GoodsInward({super.key});

  @override
  State<GoodsInward> createState() => _GoodsInwardState();
}

class _GoodsInwardState extends State<GoodsInward> {
  late double height;
  late double width;
  late String usCode;
  late int orderNumber;
  List<dynamic> docIds = [];
  String? selectedDocId;
  TextEditingController gstController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController partyNameController = TextEditingController();
  final _dateController = TextEditingController();
  String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  // Get the current date and time
  DateTime now = DateTime.now();

// Convert to ISO 8601 string (common format for APIs)
  String currentTime = DateTime.now().toIso8601String();

  // print(currentTime) // Output: e.g., 2024-12-18T14:35:20.123Z
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
  final docid = TextEditingController();      // DUPCHK1


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDocIds();
    _loadUserDetails();
  }

                 /// Get Api's method for Doc Id's //
  Future<void> fetchDocIds() async {
    final url = Uri.parse('http://192.168.1.8:8080/db/gate_gst_get_api.php');
    try {
      final response = await http.get(url);
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            docIds = data; // Ensure the type is List<dynamic>
          });
          debugPrint('Fetched DocIDs: $docIds');
        } else {
          debugPrint('Unexpected data format: $data');
        }
      } else {
        debugPrint('Failed to fetch data. Status: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error fetching data: $error');
    }
  }


  void fillFields(String docId) {
    final selectedData = docIds.firstWhere((doc) => doc['DOCID'] == docId, orElse: () => null);
    if (selectedData != null) {
      setState(() {
        gstController.text = selectedData['GST'] ?? '';
        typeController.text = selectedData['PTYPE'] ?? '';
        partyNameController.text = selectedData['PARTYID'] ?? '';
      });
      debugPrint('Selected Data: $selectedData');
    } else {
      debugPrint('No matching DOCID found for: $docId');
    }
  }

  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    usCode = prefs.getString('usCode') ?? 'UNKNOWN';
    orderNumber = prefs.getInt('orderNumber_$usCode') ?? 1;  // Start from 1 for the user

    setState(() {});
  }


  // /// Post method for Goods Inward //
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

    // final prefs = await SharedPreferences.getInstance();

    // Increment the order number
    await prefs.setInt('orderNumber_$usCode', orderNumber + 1);

    final dcNo = "$usCode/24/I/$orderNumber";
    // Construct the dynamic API endpoint
    final String url = 'http://$serverIp:$port/db/dbconnect.php';

    // HTTP headers
    final headers = {
      'Content-Type': 'application/json',
    };

    // Set up the data for the API request
    final data = {
      "GATEINMASID": "1.3277E+13",
      "CANCEL": "F",
      "SOURCEID": "0",
      "MAPNAME": "",
      "USERNAME": "eagleate",
      "MODIFIEDON": formattedDate,
      "CREATEDBY": "eagleate",
      "CREATEDON": formattedDate,
      "WKID": "",
      "APP_LEVEL": "1",
      "APP_DESC": "1",
      "APP_SLEVEL": "",
      "CANCELREMARKS": "",
      "WFROLES": "",
      "DOCDATE": docDate.text, // Extracted text
      "DELCTRL": delCtrl.text, // Extracted text
      "DEPT": dept.text, // Extracted text
      "DCNO": "$usCode/24/I/$orderNumber", // Extracted text
      "STIME": stime.text, // Extracted text
      "PARTY": partyNameController.text, // Extracted text
      "DELQTY": delQty.text, // Extracted text
      "DUPCHK": dupChk.text, // Extracted text
      "JOBCLOSE": "NO",
      "STMUSER": stmUser.text, // Extracted text
      "REMARKS": remarks.text, // Extracted text
      "ENAME": eName.text, // Extracted text
      "DCDATE": _dateController.text, // Extracted text
      "DINWNO": dinWno.text, // Extracted text
      "DINWON": dinWon.text, // Extracted text
      "DINWBY": dinWby.text, // Extracted text
      "TODEPT": toDept.text, // Extracted text
      "ATIME": aTime.text, // Extracted text
      "ITIME": iTime.text, // Extracted text
      "FINYEAR": finYear.text, // Extracted text
      "DOCID": docid.text, // This is already a string
      "SUPP": supp.text, // Extracted text
      "JOBCLOSEDBY": jobClosedBy.text, // Extracted text
      "JCLOSEDON": jClosedOn.text, // Extracted text
      "USERID": userId.text, // Extracted text
      "NPARTY": nParty.text, // Extracted text
      "PODCCHK": podcChk.text, // Extracted text
      "GST": gstController.text, // Extracted text
      "GSTYN": gstYn.text, // Extracted text
      "PODC": selectedDocId, // Extracted text
      "RECID": recId.text, // Extracted text
      "DOCMAXNO": docMaxNo.text, // Extracted text
      "DPREFIX": dPrefix.text, // Extracted text
      "DOCID1": docId1.text, // Extracted text
      "USCODE": ussCode.text, // Extracted text
      "DELREQ": delReq.text, // Extracted text
      "DOCIDOLD": docIdOld.text, // Extracted text
      "PARTY1": party1.text, // Extracted text
      "DUPCHK1": dupChk1.text, // Extracted text
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

      // Handle success
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
      }
      // Handle server-side validation errors
      else if (response.statusCode == 417) {
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

        print('Server Messages: $serverMessages');
      }
      // Handle other errors
      else {
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

        print('Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (error) {
      // Handle exceptions like network issues
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
                  // controller: exports,
                  readOnly: true,
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "NETWORK CLOTHING COMPANY PRIVATE LIMITED",
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
              Align(
                alignment: Alignment.topLeft,
                child: Text('    Doc ID:',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 16)),
              ),
              const SizedBox(height: 10),
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
                  // controller: docid,
                  style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "$usCode/24/I/$orderNumber",
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
          SizedBox(height: 14.5.h,),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "     Po/Dc No ", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 7.5.h,),
          Container(
            height: height / 15.2.h,
            width: width / 1.13.w,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade500),
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: DropdownSearch<String>(
              popupProps: const PopupProps.dialog(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Search Po/Dc No",
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  ),
                ),
              ),
              items: docIds
                  .where((doc) => doc is Map<String, dynamic> && doc['DOCID'] != null)
                  .map<String>((doc) => doc['DOCID'].toString())
                  .toList(),
              selectedItem: selectedDocId, // Use a separate variable to track selection
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.pattern,
                    color: Colors.grey.shade700,
                    size: 17.5,
                  ),
                  hintText: "",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedDocId = value ?? ''; // Store the selected value
                  podc.text = value ?? ''; // Also update the controller if needed
                  if (value != null) {
                    fillFields(value);
                  }
                });
              },
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
                  controller: gstController,
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
                  controller: typeController,
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
                  controller: partyNameController,
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
                        controller: dcNo,
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
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "     Grn qty ", weight: FontWeight.w500, color: Colors.black)),
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
                  controller: typeController,
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



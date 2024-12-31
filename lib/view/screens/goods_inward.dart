import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
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
  String deviceId = '';
  List<Map<String, dynamic>> docIds = [];
  List<Map<String, dynamic>> filteredDocIds = [];
  String? selectedDocId;
  bool isLoading = false;
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController partyNameController = TextEditingController();
  final _dateController = TextEditingController();
  String formattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());

  // Get the current date and time
  DateTime now = DateTime.now();

// Convert to ISO 8601 string (common format for APIs)
  String currentTime = DateFormat('HH.mm.ss').format(DateTime.now());

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
    fetchDeviceId();
  }

                /// Showing IMEI Number ///

  Future<void> fetchDeviceId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      setState(() {
        deviceId = androidInfo.id ?? 'Unknown Device ID'; // Retrieve Android ID
      });
    } catch (e) {
      setState(() {
        deviceId = 'Failed to retrieve Device ID';
      });
    }
  }
                 ///  Get Api's method for Doc Id's //

  Future<void> fetchDocIds() async {
    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('port') ?? '';

    if (serverIp.isEmpty || port.isEmpty) {
      debugPrint('Error: Server IP or port is not configured.');
      return;
    }

    final String url = 'http://$serverIp:$port/db/gate_gst_get_api.php';
    debugPrint('Dynamic URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          final box = Hive.box('docIdsBox');

          // Store data as JSON strings
          final List<String> jsonStringList = data.map((doc) => json.encode(doc)).toList();
          await box.put('docIds', jsonStringList);

          setState(() {
            docIds = List<Map<String, dynamic>>.from(data);
            filteredDocIds = docIds; // Initially, show all data
          });

          debugPrint('Fetched and Stored DocIDs: $docIds');
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



              /// Pass the Docid and get the other details ///

  Future<void> fetchDocDetails(String docId) async {
    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('port') ?? '';

    if (serverIp.isEmpty || port.isEmpty) {
      debugPrint('Error: Server IP or port is not configured.');
      return;
    }

    final String url = 'http://$serverIp:$port/db/gate_gst_doc_get_api.php?DOCID=$docId';
    debugPrint('Dynamic URL for details: $url');

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      print(response.contentLength);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Fetched data: $data'); // Print the response to verify the structure

        // Check if the data is a list (it should be a list of maps)
        if (data is List) {
          final docDetails = data.isNotEmpty ? data[0] : null;

          if (docDetails != null && docDetails is Map<String, dynamic>) {
            setState(() {
              gstController.text = docDetails['GST'] ?? ''; // Fill GST field
              typeController.text = docDetails['PTYPE'] ?? ''; // Fill Type field
              partyNameController.text = docDetails['PARTYID'] ?? ''; // Fill Party Name field
            });
          } else {
            debugPrint('Unexpected data format: $docDetails');
          }
        } else {
          debugPrint('Expected a List but got: $data');
        }
      } else {
        debugPrint('Failed to fetch details. Status: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error fetching details: $error');
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
    final username = prefs.getString('username') ?? ''; // Retrieve the username

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
      // "GATEINMASID": "",
      "CANCEL": "F",
      "SOURCEID": "0",
      "MAPNAME": "",
      // "USERNAME": username,
      // "MODIFIEDON": formattedDate,
      // "CREATEDBY": username,
      "CREATEDON": "",
      // "WKID": "",
      // "APP_LEVEL": "1",
      // "APP_DESC": "1",
      // "APP_SLEVEL": "",
      // "CANCELREMARKS": "",
      // "WFROLES": "",
      // "DOCDATE": formattedDate, // Extracted text
      "DELCTRL": "U Don't Have rights to delete", // Extracted text
      // "DEPT": dept.text, // Extracted text
      "DCNO": "", // Extracted text
      "STIME": "", // Extracted text
      "PARTY": party1.text, // Extracted text
      "DELQTY": delQty.text, // Extracted text
      // "DUPCHK": dupChk.text, // Extracted text
      "JOBCLOSE": "NO",
      "STMUSER": deviceId, // Extracted text
      "REMARKS": remarks.text, // Extracted text
      "ENAME": eName.text, // Extracted text
      // "DCDATE": _dateController.text, // Extracted text
      "DINWNO": dinWno.text, // Extracted text
      // "DINWON": dinWon.text, // Extracted text
      "DINWBY": dinWby.text, // Extracted text
      "TODEPT": toDept.text, // Extracted text
      "ATIME": "", // Extracted text
      "ITIME": "", // Extracted text
      "FINYEAR": "2024-2025", // Extracted text
      "DOCID": "$usCode/24/$orderNumber", // This is already a string
      "SUPP": supp.text, // Extracted text
      // "JOBCLOSEDBY": jobClosedBy.text, // Extracted text
      // "JCLOSEDON": jClosedOn.text, // Extracted text
      "USERID": userId.text, // Extracted text
      "NPARTY": nParty.text, // Extracted text
      "PODCCHK": podcChk.text, // Extracted text
      "GST": gstController.text, // Extracted text
      "GSTYN": gstYn.text, // Extracted text
      "PODC": "", // Extracted text
      "RECID": recId.text, // Extracted text
      "DOCMAXNO": docMaxNo.text, // Extracted text
      "DPREFIX": dPrefix.text, // Extracted text
      "DOCID1": "$usCode/24/$orderNumber", // Extracted text
      "USCODE": ussCode.text, // Extracted text
      "DELREQ": delReq.text, // Extracted text
      "DOCIDOLD": selectedDocId, // Extracted text
      "PARTY1": partyNameController.text, // Extracted text
      "DUPCHK1": partyNameController.text, // Extracted text
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
        //// Clear input fields
        party1.clear();
        delQty.clear();
        stmUser.clear();
        remarks.clear();
        eName.clear();
        dinWno.clear();
        dinWby.clear();
        toDept.clear();
        supp.clear();
        userId.clear();
        nParty.clear();
        podcChk.clear();
        gstController.clear();
        gstYn.clear();
        recId.clear();
        docMaxNo.clear();
        dPrefix.clear();
        ussCode.clear();
        delReq.clear();
        partyNameController.clear();
        selectedDocId = ''; // Reset other non-controller variables
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => const Dashboard()),
        // );
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
        title: const Subhead(text: "Gate Inward", weight: FontWeight.w500, color: Colors.black,),
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
                      labelText: "$usCode/24/$orderNumber",
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
              const SizedBox(height: 10),
              Container(
                height: height / 15.2.h,
                width: width / 1.13.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade500),
                  borderRadius: BorderRadius.circular(6),
                ),
                child:
                TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                    hintText: "Type to search Po/Dc No",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onChanged: (text) {
                    setState(() {
                      if (text.isEmpty) {
                        filteredDocIds = [];  // Clear suggestions when text is empty
                      } else {
                        final box = Hive.box('docIdsBox');
                        final List<String> storedDocIds = box.get('docIds', defaultValue: []);

                        // Convert JSON strings back to maps
                        final List<Map<String, dynamic>> deserializedDocIds = storedDocIds
                            .map((docString) => json.decode(docString) as Map<String, dynamic>)
                            .toList();

                        // Filter data based on user input
                        filteredDocIds = deserializedDocIds.where((doc) {
                          return doc['DOCID'].toString().toLowerCase().contains(text.toLowerCase());
                        }).toList();
                      }
                    });
                  },
                )
              ),
              const SizedBox(height: 10),
// Suggestions List - show only when there is text input and filtered results
              // Suggestions List - show only when there is text input and filtered results
              if (searchController.text.isNotEmpty && filteredDocIds.isNotEmpty)
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ListView.builder(
                    itemCount: filteredDocIds.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredDocIds.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final doc = filteredDocIds[index];
                      return ListTile(
                        title: Text(doc['DOCID']),
                        onTap: () async {
                          searchController.text = doc['DOCID'];  // Update the TextFormField with the selected DOCID
                          await fetchDocDetails(doc['DOCID']);  // Fetch details for the selected DocID
                          setState(() {
                            filteredDocIds = []; // Clear the suggestions list explicitly
                          });
                        },
                      );
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
                              _dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
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
                      labelText: currentTime,
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
              SizedBox(height: 14.5..h),
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
                  controller: delQty,
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
              SizedBox(height: 14.5..h),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(text: "     Stm User ", weight: FontWeight.w500, color: Colors.black)),
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
                  initialValue: deviceId,
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
                  child: Buttons(height: height/18.h, width: width/2.w, radius: BorderRadius.circular(7), color: Colors.blue, text: "Submit")),
              SizedBox(height: 15.h,),
          ]),
        ),
      ),
    );
  }
}



import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
// import 'package:hive/hive.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ncc/view/widgets/buttons.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:ncc/view/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Get the current date and time
  DateTime now = DateTime.now();

// Convert to ISO 8601 string (common format for APIs)
  String currentTime = DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8);

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
  final party = TextEditingController();        // PARTY
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
  final dcnumber = TextEditingController();      // DUPCHK1


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDocIds();
    _loadUserDetails();
    fetchDeviceId();
    loadSavedDocId();
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
    const String url = 'http://192.168.1.155/db/gate_gst_get_api.php';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var rawData = response.body.trim(); // Trim whitespace and newlines
        // debugPrint('Raw Response Body: $rawData');
        // Clean malformed JSON if necessary
        rawData = rawData.replaceAll(RegExp(r'\]\['), ','); // Replace `][` with `,`

        try {
          // Attempt to parse the cleaned JSON
          final data = json.decode(rawData);
          if (data is List) {
            setState(() {
              docIds = List<Map<String, dynamic>>.from(data); // Store entire dataset
              filteredDocIds = docIds; // Initially display all data
            });
            debugPrint('Fetched ${docIds.length} records successfully.');
          } else {
            debugPrint('Unexpected data format. Expected a List, got: $data');
          }
        } catch (jsonError) {
          debugPrint('JSON Parsing Error after cleaning: $jsonError');
        }
      } else {
        debugPrint('Failed to fetch data. Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
      }
    } catch (networkError) {
      debugPrint('Network Error: $networkError');
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


  TextEditingController docIdController = TextEditingController();

  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    usCode = prefs.getString('usCode') ?? 'UNKNOWN';
    orderNumber = prefs.getInt('orderNumber_$usCode') ?? 1;

    String newId = '$usCode/24/17000${orderNumber + 1}';
    prefs.setString('newUserId_$usCode', newId);

    setState(() {
      docIdController.text = newId;  // Update the controller's text with the new DocId
    });
  }
  void loadSavedDocId() async {
    final prefs = await SharedPreferences.getInstance();
    final docIdKey = 'last_docid_inward_$usCode';
    final savedDocId = prefs.getString(docIdKey);
    if (savedDocId != null) {
      setState(() {
        docIdController.text = savedDocId;
      });
    }
  }

  /// Post method for Goods Inward //
  /// Post method for Goods Inward //
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

    // Retrieve current PARTY1 and DCNO values
    final party1 = partyNameController.text;
    final DCNO = dcnumber.text;

    // Retrieve the stored duplicates list from SharedPreferences
    final storedDuplicates = prefs.getStringList('posted_combinations') ?? [];
    final newCombination = '$party1|$DCNO'; // Corrected missing initialization of newCombination

    // Unique key for Goods Inward orderNumber
    final inwardOrderKey = 'orderNumber_Inward_$usCode';
    int inwardOrderNumber = prefs.getInt(inwardOrderKey) ?? 1;
    final docIdKey = 'last_docid_inward_$usCode';




    if (storedDuplicates.contains(newCombination)) {
      // Show an error message for duplicate entry
      Get.snackbar(
        "Duplicate Entry",
        "The combination of Party Name and DC Number already exists. Please use unique values.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return; // Stop further execution
    }

    // Increment the order number
    await prefs.setInt(inwardOrderKey, inwardOrderNumber + 1);

    // Construct the dynamic API endpoint
    final String url = 'http://$serverIp:$port/db/dbconnect.php';

    // HTTP headers
    final headers = {
      'Content-Type': 'application/json',
    };

    // // Get current date and time
    // final formattedDate = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
    // final currentTime = DateTime.now().toIso8601String(); // Full ISO8601 timestamp

    // Set up the data for the API request
    final data = {
      "CANCEL": "F",
      "SOURCEID": "0",
      "MAPNAME": "",
      "USERNAME": username,
      "MODIFIEDON": formattedDate + currentTime,
      "CREATEDBY": username,
      "CREATEDON": formattedDate + currentTime,
      "DELCTRL": "U Don't Have rights to delete",
      "DEPT": typeController.text,
      "DCNO": dcnumber.text,
      "STIME": formattedDate + currentTime,
      "PARTY": party.text,
      "DELQTY": delQty.text,
      "JOBCLOSE": "NO",
      "STMUSER": deviceId,
      "REMARKS": remarks.text,
      "ENAME": "18970000000000",
      "DCDATE": _dateController.text,
      "DINWNO": dinWno.text,
      "DINWBY": dinWby.text,
      "TODEPT": toDept.text,
      "ATIME": currentTime,
      "ITIME": formattedDate + currentTime,
      "FINYEAR": "/24/",
      "DOCID": docIdController.text,
      "SUPP": supp.text,
      "USERID": username,
      "NPARTY": nParty.text,
      "PODCCHK": podcChk.text,
      "GST": gstController.text,
      "GSTYN": gstYn.text,
      "PODC": searchController.text,
      "RECID": recId.text,
      "DOCMAXNO": inwardOrderNumber,
      "DPREFIX": "$usCode/24",
      "DOCID1": docIdController.text,
      "USCODE": usCode,
      "DELREQ": delReq.text,
      "DOCIDOLD": searchController.text,
      "PARTY1": partyNameController.text,
      "DUPCHK1": "${partyNameController.text}${dcnumber.text}/24/",
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Add the new combination to the stored list
        storedDuplicates.add(newCombination);
        await prefs.setStringList('posted_combinations', storedDuplicates);

        setState(() {
          // Extract and increment DocID
          String currentDocId = docIdController.text;
          final regex = RegExp(r'(\d+)$');
          final match = regex.firstMatch(currentDocId);

          if (match != null) {
            String lastNumber = match.group(0)!;
            int incrementedNumber = int.parse(lastNumber) + 1;
            String newDocId = currentDocId.replaceFirst(lastNumber, incrementedNumber.toString());

            // Save both the incremented order number and DocID to SharedPreferences
            prefs.setInt(inwardOrderKey, inwardOrderNumber + 1);
            prefs.setString(docIdKey, newDocId);

            docIdController.text = newDocId;
          }
        });

        // Show success snackbar
        Get.snackbar(
          "Success",
          "Document posted successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear input fields
        // party1.clear();
        dcnumber.clear();
        delQty.clear();
        typeController.clear();
        stmUser.clear();
        remarks.clear();
        dinWno.clear();
        dinWby.clear();
        toDept.clear();
        supp.clear();
        nParty.clear();
        podcChk.clear();
        gstController.clear();
        gstYn.clear();
        recId.clear();
        delReq.clear();
        partyNameController.clear();
        searchController.clear();
        dcnumber.clear();
        _dateController.clear();
        selectedDocId = ''; // Reset other non-controller variables
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
        String responseBody = response.body;
        Get.snackbar(
          "Error",
          "Request failed with status: ${response.statusCode}\n\nResponse: $responseBody",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('Error: ${response.statusCode}');
        print('Response Body: $responseBody');
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      if(width<=1000){
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
                      // controller: docIdController,
                      style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),
                      decoration: InputDecoration(
                          labelText: docIdController.text,
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        ),
                        onChanged: (text) {
                          setState(() {
                            if (text.isEmpty) {
                              filteredDocIds = []; // Clear suggestions when text is empty
                            } else {
                              // Filter data based on user input
                              filteredDocIds = docIds.where((doc) {
                                final docId = doc['DOCID']?.toString() ?? '';
                                return docId.toLowerCase().contains(text.toLowerCase());
                              }).toList();
                            }
                          });
                        },
                      )

                    // Column(
                    //   children: [
                    //     Padding(
                    //       padding: const EdgeInsets.all(8.0),
                    //       child: TextFormField(
                    //         controller: searchController,
                    //         decoration: InputDecoration(
                    //           prefixIcon: Icon(
                    //             Icons.search,
                    //             color: Colors.grey.shade700,
                    //             size: 20,
                    //           ),
                    //           hintText: "Type to search Po/Dc No",
                    //           border: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(10),
                    //             borderSide: BorderSide(color: Colors.grey.shade300),
                    //           ),
                    //           contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    //         ),
                    //         onChanged: (text) {
                    //           debugPrint('Fetched ${docIds.length} records successfully.');
                    //           setState(() {
                    //             debugPrint('Fetched ${docIds.length} records successfully.');
                    //             if (text.isEmpty) {
                    //               filteredDocIds = docIds; // Show all data when search is empty
                    //             } else {
                    //               filteredDocIds = docIds.where((doc) {
                    //                 final docId = doc['DOCID']?.toString() ?? '';
                    //                 return docId.toLowerCase().contains(text.toLowerCase());
                    //               }).toList();
                    //             }
                    //           });
                    //         },
                    //       ),
                    //     ),
                    //     Expanded(
                    //       child: ListView.builder(
                    //         itemCount: filteredDocIds.length,
                    //         itemBuilder: (context, index) {
                    //           return ListTile(
                    //             title: Text(filteredDocIds[index]['DOCID'] ?? 'Unknown'),
                    //             subtitle: Text(filteredDocIds[index].toString()),
                    //           );
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),

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
                            controller: dcnumber,
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
                            Icons.desktop_mac,
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
        )
    );
  }
}
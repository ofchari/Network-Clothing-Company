import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ncc/view/widgets/buttons.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:ncc/view/widgets/text.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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

  String currentTime =
      DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8);

  /// Controller for post method //
  final gateInMasId = TextEditingController(); // GATEINMASID
  final cancel = TextEditingController(); // CANCEL
  final sourceId = TextEditingController(); // SOURCEID
  final mapName = TextEditingController(); // MAPNAME
  final username = TextEditingController(); // USERNAME
  final modifiedOn = TextEditingController(); // MODIFIEDON
  final createdBy = TextEditingController(); // CREATEDBY
  final createdOn = TextEditingController(); // CREATEDON
  final wkId = TextEditingController(); // WKID
  final appLevel = TextEditingController(); // APP_LEVEL
  final appDesc = TextEditingController(); // APP_DESC
  final appSLevel = TextEditingController(); // APP_SLEVEL
  final cancelRemarks = TextEditingController(); // CANCELREMARKS
  final wfRoles = TextEditingController(); // WFROLES
  final docDate = TextEditingController(); // DOCDATE
  final delCtrl = TextEditingController(); // DELCTRL
  final dept = TextEditingController(); // DEPT
  final dcNo = TextEditingController(); // DCNO
  final stime = TextEditingController(); // STIME
  final party = TextEditingController(); // PARTY
  final delQty = TextEditingController(); // DELQTY
  final dupChk = TextEditingController(); // DUPCHK
  final jobClose = TextEditingController(); // JOBCLOSE
  final stmUser = TextEditingController(); // STMUSER
  final remarks = TextEditingController(); // REMARKS
  final eName = TextEditingController(); // ENAME
  final dcDate = TextEditingController(); // DCDATE
  final dinWno = TextEditingController(); // DINWNO
  final dinWon = TextEditingController(); // DINWON
  final dinWby = TextEditingController(); // DINWBY
  final toDept = TextEditingController(); // TODEPT
  final aTime = TextEditingController(); // ATIME
  final iTime = TextEditingController(); // ITIME
  final finYear = TextEditingController(); // FINYEAR
  // final docId = TextEditingController();        // DOCID
  final supp = TextEditingController(); // SUPP
  final jobClosedBy = TextEditingController(); // JOBCLOSEDBY
  final jClosedOn = TextEditingController(); // JCLOSEDON
  final userId = TextEditingController(); // USERID
  final nParty = TextEditingController(); // NPARTY
  final podcChk = TextEditingController(); // PODCCHK
  // final gst = TextEditingController();          // GST
  final gstYn = TextEditingController(); // GSTYN
  final podc = TextEditingController(); // PODC
  final recId = TextEditingController(); // RECID
  final docMaxNo = TextEditingController(); // DOCMAXNO
  final dPrefix = TextEditingController(); // DPREFIX
  final docId1 = TextEditingController(); // DOCID1
  final ussCode = TextEditingController(); // USCODE
  final delReq = TextEditingController(); // DELREQ
  final docIdOld = TextEditingController(); // DOCIDOLD
  final party1 = TextEditingController(); // PARTY1
  final dupChk1 = TextEditingController(); // DUPCHK1
  final docid = TextEditingController(); // DUPCHK1
  final dcnumber = TextEditingController(); // DUPCHK1

  @override
  void initState() {
    super.initState();
    fetchAndSetDocId();
    fetchDocIds();
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
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('port') ?? '';

    if (serverIp.isEmpty || port.isEmpty) {
      debugPrint('Error: Server IP or port is not configured.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String url = 'http://$serverIp:$port/gate_gst_get_api';
    debugPrint('Fetching from URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var rawData = response.body.trim(); // Trim whitespace and newlines
        rawData =
            rawData.replaceAll(RegExp(r'\]\['), ','); // Fix malformed JSON
        print('Raw Response: ${response.body}');

        try {
          final data = json.decode(rawData);
          if (data is List) {
            setState(() {
              docIds = List<Map<String, dynamic>>.from(data);
              filteredDocIds = docIds;
              isLoading = false;
            });
            debugPrint('Fetched ${docIds.length} records successfully.');
          } else {
            debugPrint('Unexpected data format. Expected a List, got: $data');
            setState(() {
              isLoading = false;
            });
          }
        } catch (jsonError) {
          debugPrint('JSON Parsing Error after cleaning: $jsonError');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        debugPrint('Failed to fetch data. Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (networkError) {
      debugPrint('Network Error: $networkError');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Pass the Docid and get the other details ///
  Future<void> fetchDocDetails(String docId) async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('port') ?? '';

    if (serverIp.isEmpty || port.isEmpty) {
      debugPrint('Error: Server IP or port is not configured.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String url =
        'http://$serverIp:$port/gate_gst_doc_get_api?DOCID=$docId';
    debugPrint('Dynamic URL for details: $url');

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      print(response.contentLength);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint(
            'Fetched data: $data'); // Print the response to verify the structure

        // Check if the data is a list (it should be a list of maps)
        if (data is List) {
          final docDetails = data.isNotEmpty ? data[0] : null;

          if (docDetails != null && docDetails is Map<String, dynamic>) {
            if (!mounted) return;
            setState(() {
              gstController.text = docDetails['GST'] ?? '';
              typeController.text = docDetails['PTYPE'] ?? '';
              party.text = docDetails['PARTYMASID']?.toString() ?? '';
              partyNameController.text = docDetails['PARTYID'] ?? '';
              isLoading = false;
            });
          } else {
            debugPrint('Unexpected data format: $docDetails');
            setState(() {
              isLoading = false;
            });
          }
        } else {
          debugPrint('Expected a List but got: $data');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        debugPrint('Failed to fetch details. Status: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      debugPrint('Error fetching details: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  TextEditingController docIdController = TextEditingController();

  // Add this at the top of your class
  static const String fixedFinancialYear = '25';

  /// Modified fetchAndSetDocId method
  Future<void> fetchAndSetDocId() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('port') ?? '';
    final username = prefs.getString('username') ?? '';

    if (serverIp.isEmpty || port.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String url =
        'http://$serverIp:$port/get_docid_api?USERNAME=$username';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty && data[0]['DOCID'] != null) {
          final serverDocId = data[0]['DOCID'] as String;

          // Increment the server-provided DOCID for display
          final displayedDocId = incrementDocId(serverDocId);

          setState(() {
            docIdController.text = displayedDocId;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        showErrorSnackBar(
            'Failed to fetch DOCID. Status: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showErrorSnackBar('Error fetching DOCID: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String incrementDocId(String currentId) {
    try {
      List<String> parts = currentId.split('/');
      if (parts.length < 3) return currentId;

      // Keep original padding length
      int paddingLength = parts[2].length;

      // Parse and increment number
      int sequence = int.parse(parts[2]);
      sequence++;

      // Rebuild with padding
      return '${parts[0]}/${parts[1]}/${sequence.toString().padLeft(paddingLength, '0')}';
    } catch (e) {
      debugPrint('Error incrementing DocID: $e');
      return currentId;
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Method to extract the numeric part from DocID
  String extractNumericPart(String docId) {
    final RegExp regex = RegExp(r'(\d+)$'); // Matches the last numeric part
    final match = regex.firstMatch(docId);

    if (match != null) {
      return match.group(0)!; // Return the matched numeric part
    }

    return '0'; // Return 0 if no numeric part is found
  }

  // Method to extract the prefix (e.g., "Eag") from fetchsetdocid
  String extractUsCode(String docId) {
    if (docId.isEmpty) return '';

    final RegExp regex =
        RegExp(r'^([A-Za-z]+)(?=/)'); // Matches the prefix before the first "/"
    final match = regex.firstMatch(docId);

    if (match != null) {
      return match.group(1)!; // Return the extracted prefix
    }
    return ''; // Return empty string if no match is found
  }

  /// Function to generate barcode as PNG bytes with improved quality ///
  Uint8List generateBarcodeSvgBytes(String data) {
    // This is only needed if you still want to generate raw bytes for some reason
    // For example, if you need to use it with a different rendering approach
    final bc = Barcode.code128();
    final svg = bc.toSvg(data, width: 300, height: 100);
    return Uint8List.fromList(utf8.encode(svg));
  }

  /// Post method for Goods Inward with Barcode Generation //
  Future<void> MobileDocument(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    HttpClient client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('port') ?? '';
    final username = prefs.getString('username') ?? '';

    if (serverIp.isEmpty || port.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Configuration Error'),
          content: const Text(
              'Server IP and port are not configured. Please set them in the settings.'),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        ),
      );
      return;
    }

    final partyName = partyNameController.text;
    final dcNum = dcnumber.text;

    final storedDuplicates = prefs.getStringList('posted_combinations') ?? [];
    final newCombination = '$partyName|$dcNum';

    if (docIdController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Document ID is missing. Please refresh and try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    String lastNumber = extractNumericPart(docIdController.text);
    String usCode = extractUsCode(docIdController.text);

    if (storedDuplicates.contains(newCombination)) {
      Get.snackbar(
        "Duplicate Entry",
        "The combination of Party Name and DC Number already exists. Please use unique values.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String url = 'http://$serverIp:$port/gatemas_inwards';

    final headers = {
      'Content-Type': 'application/json',
    };

    final String postedDocId = docIdController.text; // Store before any changes

    String formattedDateTime =
        DateFormat('yyyy-MM-ddHH:mm:ss').format(DateTime.now());

    // Validation checks
    if (dcnumber.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "DC Number cannot be empty",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (_dateController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "DC Date is required",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (delQty.text.trim().isEmpty || int.tryParse(delQty.text) == null) {
      Get.snackbar(
        "Error",
        "Grn is required and must be a number",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (partyNameController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Party Name is required",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final data = {
      "CANCEL": "F",
      "SOURCEID": "0",
      "MAPNAME": "",
      "USERNAME": username,
      "MODIFIEDON": formattedDateTime,
      "CREATEDBY": username,
      "CREATEDON": formattedDateTime,
      "DELCTRL": "U Don't Have rights to delete",
      "DEPT": typeController.text,
      "DCNO": dcnumber.text,
      "STIME": formattedDateTime,
      "PARTY": party.text,
      "DELQTY": delQty.text,
      "JOBCLOSE": "NO",
      "STMUSER": deviceId,
      "REMARKS": remarks.text,
      "ENAME": "18970000000000",
      "DCDATE": _dateController.text,
      "DOCDATE": formattedDateTime.split('T')[0], // Keeping only date part
      "DINWNO": dinWno.text,
      "DINWBY": dinWby.text,
      "TODEPT": "0",
      "ATIME": formattedDateTime.substring(11), // Extract only time part
      "ITIME": formattedDateTime,
      "FINYEAR": "/25/", // Kept as /25/ for consistency
      "DOCID": postedDocId, // Use the captured DocId
      "SUPP": supp.text,
      "USERID": username,
      "NPARTY": nParty.text,
      "PODCCHK": podcChk.text,
      "GST": gstController.text,
      "GSTYN": gstYn.text,
      "PODC": searchController.text,
      "RECID": recId.text,
      "DOCMAXNO": lastNumber,
      "DPREFIX": "$usCode/25",
      "DOCID1": postedDocId, // Use the captured DocId
      "USCODE": usCode,
      "DELREQ": delReq.text,
      "DOCIDOLD": searchController.text,
      "PARTY1": partyNameController.text,
      "DUPCHK1": "${partyNameController.text}${dcnumber.text}/25/",
    };

    print('Request Data: $data');
    print('Dynamic URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );
      print('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Add to stored duplicates
        storedDuplicates.add(newCombination);
        await prefs.setStringList('posted_combinations', storedDuplicates);

        // Get fresh DOCID from server after successful post
        await fetchAndSetDocId();

        Get.snackbar(
          "Success",
          "Document posted successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Show Barcode Dialog after successful post
        showBarcodeDialog(context, postedDocId);

        // Clear all fields after successful submission
        clearAllFields();

        // Refresh document IDs
        fetchDocIds();
      } else if (response.statusCode == 417) {
        final responseJson = json.decode(response.body);
        final serverMessages =
            responseJson['_server_messages'] ?? 'No server messages found';

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
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoading = false;
                  });
                },
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
        setState(() {
          isLoading = false;
        });
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
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        ),
      );
    }
  }

  /// Clear all form fields
  void clearAllFields() {
    setState(() {
      searchController.clear();
      gstController.clear();
      typeController.clear();
      partyNameController.clear();
      _dateController.clear();
      delQty.clear();
      remarks.clear();
      dinWno.clear();
      dinWby.clear();
      toDept.clear();
      supp.clear();
      nParty.clear();
      podcChk.clear();
      gstYn.clear();
      recId.clear();
      delReq.clear();
      dcnumber.clear();
      party.clear();

      // Clear the filtered results
      selectedDocId = null;
      filteredDocIds = [];

      isLoading = false;
    });
  }

  void showBarcodeDialog(BuildContext context, String docId) {
    if (docId.isEmpty) {
      print("Error: Empty DocID for barcode");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Barcode',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 300,
              height: 150,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: BarcodeWidget(
                barcode: Barcode.code128(),
                data: docId,
                width: 300,
                height: 100,
                drawText: false,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              docId,
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _printBarcode(docId),
            icon: const Icon(Icons.print),
            label: const Text("Print"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

// 4. Replace your _printBarcode method with this improved version
  Future<void> _printBarcode(String data) async {
    final pdf = pw.Document();

    // Generate SVG barcode directly for PDF
    final barcode = Barcode.code128();
    final svg = barcode.toSvg(data, width: 300, height: 100);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.SvgImage(svg: svg),
              pw.SizedBox(height: 16),
              pw.Text(
                data,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;
        if (width <= 1000) {
          return _smallBuildLayout();
        } else {
          return const Text("Please Make sure Your device is in portrait view");
        }
      },
    );
  }

  Widget _smallBuildLayout() {
    /// Define Sizes //
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
        backgroundColor: const Color(0xfff1f2f4),
        appBar: AppBar(
          title: const Subhead(
            text: "Gate Inward",
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
            child: Column(children: [
              SizedBox(
                height: 10.h,
              ),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(
                      text: "     Exporter :",
                      weight: FontWeight.w500,
                      color: Colors.black)),
              SizedBox(
                height: 5.h,
              ),
              Container(
                height: height / 15.2.h,
                width: width / 1.09.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6.r)),
                child: TextFormField(
                  readOnly: true,
                  style: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black)),
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
                      border: InputBorder.none),
                ),
              ),
              SizedBox(
                height: 13.h,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text('    Doc ID:',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w500, fontSize: 16)),
              ),
              const SizedBox(height: 10),
              Container(
                height: height / 15.2.h,
                width: width / 1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade500),
                    borderRadius: BorderRadius.circular(6.r)),
                child: TextFormField(
                  style: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: docIdController.text,
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon: Icon(
                        Icons.security_update_good_rounded,
                        color: Colors.grey.shade700,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none),
                ),
              ),
              SizedBox(
                height: 14.5.h,
              ),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(
                      text: "     Po/Dc No ",
                      weight: FontWeight.w500,
                      color: Colors.black)),
              SizedBox(
                height: 7.5.h,
              ),
              const SizedBox(height: 10),
              Container(
                  height: height / 15.2.h,
                  width: width / 1.13.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade500),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextFormField(
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
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                    ),
                    onChanged: (text) {
                      setState(() {
                        if (text.isEmpty) {
                          filteredDocIds =
                              []; // Clear suggestions when text is empty
                        } else {
                          filteredDocIds = docIds.where((doc) {
                            final docId = doc['DOCID']?.toString() ?? '';
                            return docId
                                .toLowerCase()
                                .contains(text.toLowerCase());
                          }).toList();
                        }
                      });
                    },
                  )),
              const SizedBox(height: 10),
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
                          searchController.text = doc[
                              'DOCID']; // Update the TextFormField with the selected DOCID
                          await fetchDocDetails(doc[
                              'DOCID']); // Fetch details for the selected DocID
                          setState(() {
                            filteredDocIds =
                                []; // Clear the suggestions list explicitly
                          });
                        },
                      );
                    },
                  ),
                ),
              SizedBox(
                height: 14.5.h,
              ),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(
                      text: "     GST No ",
                      weight: FontWeight.w500,
                      color: Colors.black)),
              SizedBox(
                height: 7.5.h,
              ),
              Container(
                height: height / 15.2.h,
                width: width / 1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade500),
                    borderRadius: BorderRadius.circular(6.r)),
                child: TextFormField(
                  controller: gstController,
                  style: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon: Icon(
                        Icons.security_update_good_rounded,
                        color: Colors.grey.shade700,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none),
                ),
              ),
              SizedBox(
                height: 14.5.h,
              ),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(
                      text: "     Type ",
                      weight: FontWeight.w500,
                      color: Colors.black)),
              SizedBox(
                height: 7.5.h,
              ),
              Container(
                height: height / 15.2.h,
                width: width / 1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade500),
                    borderRadius: BorderRadius.circular(6.r)),
                child: TextFormField(
                  controller: typeController,
                  style: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon: Icon(
                        Icons.merge_type,
                        color: Colors.grey.shade700,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none),
                ),
              ),
              SizedBox(
                height: 14.5.h,
              ),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(
                      text: "     Party Name ",
                      weight: FontWeight.w500,
                      color: Colors.black)),
              SizedBox(
                height: 7.5.h,
              ),
              Container(
                height: height / 15.2.h,
                width: width / 1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade500),
                    borderRadius: BorderRadius.circular(6.r)),
                child: TextFormField(
                  controller: partyNameController,
                  style: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black)),
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
                      border: InputBorder.none),
                ),
              ),
              SizedBox(
                height: 14.5.h,
              ),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(
                      text: "      DC No/Dt",
                      weight: FontWeight.w500,
                      color: Colors.black)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: height / 15.2.h,
                      width: width / 2.2.w,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey.shade500),
                          borderRadius: BorderRadius.circular(6.r)),
                      child: TextFormField(
                        controller: dcnumber,
                        style: GoogleFonts.dmSans(
                            textStyle: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black)),
                        decoration: InputDecoration(
                            labelText: "",
                            labelStyle: GoogleFonts.sora(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            prefixIcon: Icon(
                              Icons.data_exploration_outlined,
                              color: Colors.grey.shade700,
                              size: 17.5,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                            border: InputBorder.none),
                      ),
                    ),
                    Container(
                      height: height / 15.2.h,
                      width: width / 2.2.w,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey.shade500),
                          borderRadius: BorderRadius.circular(6.r)),
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
                            _dateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        },
                        style: GoogleFonts.dmSans(
                            textStyle: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black)),
                        decoration: InputDecoration(
                            labelText: "Date",
                            labelStyle: GoogleFonts.sora(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            prefixIcon: Icon(
                              Icons.date_range,
                              color: Colors.grey.shade700,
                              size: 17.5,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 14.5.h,
              ),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(
                      text: "     Time",
                      weight: FontWeight.w500,
                      color: Colors.black)),
              SizedBox(
                height: 7.5.h,
              ),
              Container(
                height: height / 15.2.h,
                width: width / 1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade500),
                    borderRadius: BorderRadius.circular(6.r)),
                child: TextFormField(
                  readOnly: true,
                  style: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: currentTime,
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon: Icon(
                        Icons.alarm,
                        color: Colors.grey.shade700,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none),
                ),
              ),
              SizedBox(height: 14.5.h),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(
                      text: "     Grn qty ",
                      weight: FontWeight.w500,
                      color: Colors.black)),
              SizedBox(
                height: 7.5.h,
              ),
              Container(
                height: height / 15.2.h,
                width: width / 1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade500),
                    borderRadius: BorderRadius.circular(6.r)),
                child: TextFormField(
                  controller: delQty,
                  style: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon: Icon(
                        Icons.merge_type,
                        color: Colors.grey.shade700,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none),
                ),
              ),
              SizedBox(height: 14.5.h),
              const Align(
                  alignment: Alignment.topLeft,
                  child: MyText(
                      text: "     Stm User ",
                      weight: FontWeight.w500,
                      color: Colors.black)),
              SizedBox(
                height: 7.5.h,
              ),
              Container(
                height: height / 15.2.h,
                width: width / 1.13.w,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade500),
                    borderRadius: BorderRadius.circular(6.r)),
                child: TextFormField(
                  initialValue: deviceId,
                  style: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black)),
                  decoration: InputDecoration(
                      labelText: "",
                      labelStyle: GoogleFonts.sora(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      prefixIcon: Icon(
                        Icons.desktop_mac,
                        color: Colors.grey.shade700,
                        size: 17.5,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      border: InputBorder.none),
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              GestureDetector(
                  onTap: () {
                    MobileDocument(context);
                  },
                  child: Buttons(
                      height: height / 18.h,
                      width: width / 2.w,
                      radius: BorderRadius.circular(7),
                      color: Colors.blue,
                      text: "Submit")),
              SizedBox(
                height: 15.h,
              ),
            ]),
          ),
        ));
  }
}

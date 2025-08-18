import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ncc/view/screens/scanner.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String deviceId = '';
  bool isEditable = false;
  bool _isSnackBarShown = false; // Track if snackbar is already shown
  // final _dateController = TextEditingController();
  final _dcNoController = TextEditingController();
  final _dcDateController = TextEditingController();
  final _partyController = TextEditingController();
  final _delQtyController = TextEditingController();

  // String formattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  String formattedDateTime =
      DateFormat('yyyy-MM-ddHH:mm:ss').format(DateTime.now());

  // Get the current date and time
  DateTime now = DateTime.now();

// Convert to ISO 8601 string (common format for APIs)
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
  // final party = TextEditingController();        // PARTY
  final delQty = TextEditingController(); // DELQTY
  final dupChk = TextEditingController(); // DUPCHK
  final jobClose = TextEditingController(); // JOBCLOSE
  final stmUser = TextEditingController(); // STMUSER
  final remarks = TextEditingController(); // REMARKS
  // final eName = TextEditingController();        // ENAME
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
  final JJFORMNO = TextEditingController(); // DUPCHK1

  // Method to fetch data from API and populate fields

  Future<void> fetchAndPopulateData(String dcNo) async {
    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('port') ?? '';

    if (serverIp.isEmpty || port.isEmpty) {
      if (!_isSnackBarShown) {
        _isSnackBarShown = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Server IP and port are not configured. Please set them in the settings.'),
          ),
        );
      }
      return;
    }

    // Encode the dcNo to handle special characters
    final encodedDcNo = Uri.encodeComponent(dcNo);
    print(encodedDcNo);

    // Append the encoded dcNo to the URL as a query parameter
    final String url =
        'http://$serverIp:$port/outwarddc_view_get_api?docid=$encodedDcNo';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);

        // Ensure the data is a List before calling `firstWhere`
        if (decodedResponse is List) {
          final record = decodedResponse.firstWhere(
            (item) => item['DOCID'] == dcNo,
            orElse: () => null,
          );

          if (record != null) {
            setState(() {
              _dcNoController.text = dcNo; // Set the scanned code
              _dcDateController.text = record['DOCDATE'] ?? '';
              _partyController.text = record['PARTYID'] ?? '';
              _delQtyController.text = record['TOTQTY']?.toString() ?? '';
              _isSnackBarShown = false;
            });
          } else {
            showError('No record found for DC No: $dcNo');
          }
        } else if (decodedResponse is Map) {
          // If the response is a single record (Map), check its DOCID
          if (decodedResponse['DOCID'] == dcNo) {
            setState(() {
              _dcNoController.text = dcNo; // Set the scanned code
              _dcDateController.text = decodedResponse['DOCDATE'] ?? '';
              _partyController.text = decodedResponse['PARTYID'] ?? '';
              _delQtyController.text =
                  decodedResponse['TOTQTY']?.toString() ?? '';
              _isSnackBarShown = false;
            });
          } else {
            showError('No matching record found for DC No: $dcNo');
          }
        } else {
          showError('Unexpected data format from server.');
        }
      } else {
        showError('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error fetching data: $e');
    }
  }

  TextEditingController docIdController = TextEditingController();

  // Future<String> incrementDocId(String docId) async {
  //   try {
  //     // Get the fixed middle segment from user preferences
  //     final prefs = await SharedPreferences.getInstance();
  //     final fixedMiddle =
  //         prefs.getString('finYear') ?? '25'; // Default to 25 if not set
  //
  //     // Split the DocID into parts using '/'
  //     final parts = docId.split('/');
  //
  //     if (parts.length != 3) {
  //       throw FormatException('Invalid DocID format');
  //     }
  //
  //     // Parse the last part as integer
  //     int lastNumber = int.parse(parts[2]);
  //
  //     // Increment and preserve padding
  //     final newLast = (lastNumber + 1).toString().padLeft(parts[2].length, '0');
  //
  //     // Reconstruct with fixed middle segment
  //     return '${parts[0]}/$fixedMiddle/$newLast';
  //   } catch (e) {
  //     debugPrint('Error incrementing DocID: $e');
  //     return docId;
  //   }
  // }

  /// Update fetchAndSetDocId to use fixed middle segment

// Update these methods in the GoodsOutward class

// Remove the old incrementDocId function and replace with this single version
  String incrementDocId(String docId) {
    try {
      List<String> parts = docId.split('/');
      if (parts.length < 3) return docId;

      // Keep original padding length
      int paddingLength = parts[2].length;

      // Parse and increment number
      int sequence = int.parse(parts[2]);
      sequence++;

      // Rebuild with padding
      return '${parts[0]}/${parts[1]}/${sequence.toString().padLeft(paddingLength, '0')}';
    } catch (e) {
      debugPrint('Error incrementing DocID: $e');
      return docId;
    }
  }

// Update fetchAndSetDocId to use the single increment function
  Future<void> fetchAndSetDocId() async {
    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('port') ?? '';
    final username = prefs.getString('username') ?? '';

    if (serverIp.isEmpty || port.isEmpty) return;

    final String url =
        'http://$serverIp:$port/get_docid_out_api?USERNAME=$username';

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
          });
        }
      }
    } catch (e) {
      showErrorSnackBar('Error fetching DOCID: $e');
    }
  }

  bool _isValidDocId(String docId) {
    final parts = docId.split('/');
    return parts.length == 3 &&
        int.tryParse(parts[1]) != null &&
        int.tryParse(parts[2]) != null;
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

  /// Post method for this Goods Outward //
  Future<void> MobileDocument(BuildContext context) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('port') ?? '';
    final username = prefs.getString('username') ?? '';
    final storedDcNumbersKey = 'posted_dc_numbers';

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
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    String currentDocId = docIdController.text;
    RegExp regex = RegExp(r'(\d+)$');
    Match? match = regex.firstMatch(currentDocId);

    if (match == null) {
      Get.snackbar("Error", "Invalid DocID format",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    final storedDcNumbers = prefs.getStringList(storedDcNumbersKey) ?? [];
    final scannedDcNo = _dcNoController.text.trim();
    String lastNumber = extractNumericPart(docIdController.text);

    if (scannedDcNo.isEmpty) {
      Get.snackbar("Validation Error",
          "DC Number cannot be empty. Please scan a valid DC Number.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    if (storedDcNumbers.contains(scannedDcNo)) {
      Get.snackbar("Duplicate Entry",
          "The DC Number '$scannedDcNo' has already been posted. Please scan a unique DC Number.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    // ✅ Generate a fresh timestamp for each post
    String formattedDateTime =
        DateFormat('yyyy-MM-ddHH:mm:ss').format(DateTime.now());

    final String url = 'http://$serverIp:$port/outward_post_api';

    final headers = {
      'Content-Type': 'application/json',
    };

    final data = {
      "CANCEL": "F",
      "SOURCEID": "0",
      "MAPNAME": "",
      "USERNAME": username,
      "MODIFIEDON": formattedDateTime,
      "CREATEDBY": username,
      "CREATEDON": formattedDateTime,
      "WKID": "",
      "APP_LEVEL": "1",
      "APP_DESC": "1",
      "APP_SLEVEL": "",
      "CANCELREMARKS": "",
      "WFROLES": "",
      "DOCDATE": formattedDateTime.split('T')[0],
      "DCNO": scannedDcNo,
      "STIME": formattedDateTime,
      "PARTY": _partyController.text,
      "DELQTY": _delQtyController.text,
      "JOBCLOSE": "NO",
      "STMUSER": deviceId,
      "REMARKS": remarks.text,
      "JJFORMNO": JJFORMNO.text,
      "DCNOS": "",
      "ENME": "18970000000000",
      "ATIME": formattedDateTime.substring(11),
      "ITIME": formattedDateTime,
      "DCDATE": _dcDateController.text,
      "RECID": recId.text,
      "USERID": username,
      "FINYEAR": "25",
      "DOCMAXNO": match.group(1) ?? '',
      "DPREFIX": dPrefix.text,
      "DOCID": docIdController.text,
      "USCODE": ussCode.text
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        storedDcNumbers.add(scannedDcNo);
        await prefs.setStringList(storedDcNumbersKey, storedDcNumbers);

        // Remove local increment logic and replace with:
        await fetchAndSetDocId(); // Get fresh DOCID from server

        int currentNumber = int.parse(match.group(1)!);
        String prefix = currentDocId.substring(
            0, currentDocId.length - match.group(1)!.length);
        int nextNumber = currentNumber + 1;
        String nextDocId =
            '$prefix${nextNumber.toString().padLeft(match.group(1)!.length, '0')}';

        setState(() {
          docIdController.text = nextDocId;
        });

        Get.snackbar("Success", "Goods Outward Document posted successfully!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);

        _dcNoController.clear();
        _partyController.clear();
        _delQtyController.clear();
        stmUser.clear();
        remarks.clear();
        JJFORMNO.clear();
        _dcDateController.clear();
        recId.clear();
        dPrefix.clear();
        ussCode.clear();
      } else if (response.statusCode == 417) {
        final responseJson = json.decode(response.body);
        final serverMessages =
            responseJson['_server_messages'] ?? 'No server messages found';

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Message'),
            content: SingleChildScrollView(child: Text(serverMessages)),
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
        Get.snackbar("Error",
            "Request failed with status: ${response.statusCode}\n\nResponse: $responseBody",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (error) {
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

  Future<void> openMobileScanner() async {
    try {
      final scannedCode = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
      );

      if (scannedCode != null && scannedCode is String) {
        // Clear previous data first
        setState(() {
          _dcDateController.clear();
          _partyController.clear();
          _delQtyController.clear();
          _dcNoController.text = scannedCode; // Set the confirmed DC number
        });

        // Then fetch and populate other data
        await fetchAndPopulateData(scannedCode);
      }
    } catch (e) {
      if (!mounted) return;

      if (!_isSnackBarShown) {
        _isSnackBarShown = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning barcode: $e'),
            duration: const Duration(seconds: 2),
            onVisible: () {
              Future.delayed(const Duration(seconds: 2), () {
                _isSnackBarShown = false;
              });
            },
          ),
        );
      }
    }
  }

  void showError(String message) {
    if (!_isSnackBarShown) {
      _isSnackBarShown = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _dcNoController.dispose();
    _dcDateController.dispose();
    _partyController.dispose();
    _delQtyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAndSetDocId();
    fetchAndPopulateData;
    fetchDeviceId();
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
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    // Responsive breakpoints
    bool isTablet = width > 600;
    bool isLargeScreen = width > 900;

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Subhead(
          text: "Gate Outward",
          weight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
        toolbarHeight: isTablet ? 80.h : 70.h,
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.grey.withOpacity(0.1),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 32.w : (isTablet ? 24.w : 16.w),
            vertical: 14.h,
          ),
          child: Column(
            children: [
              // Main content area - expandable
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                child: Container(
                  height: 530.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24.w : 20.w),
                    child: SingleChildScrollView(
                      child: _buildResponsiveContent(isTablet, isLargeScreen),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Submit button - fixed at bottom
              _buildSubmitButton(isTablet, isLargeScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveContent(bool isTablet, bool isLargeScreen) {
    double sectionSpacing = isTablet ? 18.h : 14.h;

    if (isLargeScreen) {
      // Two-column layout for large screens
      return Column(
        children: [
          // First row - Exporter (full width)
          // _buildExporterField(isTablet),
          // SizedBox(height: sectionSpacing),

          // Second row - Gate DC and DC No
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildGateDcField(isTablet),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: _buildDcNoField(isTablet),
              ),
            ],
          ),
          SizedBox(height: sectionSpacing),

          // Third row - DC Date and Party
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDcDateField(isTablet),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: _buildPartyField(isTablet),
              ),
            ],
          ),
          SizedBox(height: sectionSpacing),

          // Fourth row - Delqty and Stm User
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDelQtyField(isTablet),
              ),
              SizedBox(width: 20.w),
              // Expanded(
              //   child: _buildStmUserField(isTablet),
              // ),
            ],
          ),
        ],
      );
    } else {
      // Single column layout for mobile and tablets
      return Column(
        children: [
          // _buildExporterField(isTablet),
          // SizedBox(height: sectionSpacing),
          _buildGateDcField(isTablet),
          SizedBox(height: sectionSpacing),
          _buildDcNoField(isTablet),
          SizedBox(height: sectionSpacing),
          _buildDcDateField(isTablet),
          SizedBox(height: sectionSpacing),
          _buildPartyField(isTablet),
          SizedBox(height: sectionSpacing),
          _buildDelQtyField(isTablet),
          // SizedBox(height: sectionSpacing),
          // _buildStmUserField(isTablet),
        ],
      );
    }
  }

  Widget _buildExporterField(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Exporter",
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: isTablet ? 56.h : 52.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextFormField(
            readOnly: true,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: "NETWORK CLOTHING COMPANY PRIVATED LIMITED",
              labelStyle: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.home_work_outlined,
                  color: Colors.blue.shade600,
                  size: 18.w,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGateDcField(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gate DC No",
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: isTablet ? 56.h : 52.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextFormField(
            readOnly: true,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: docIdController.text,
              labelStyle: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.dashboard_customize_rounded,
                  color: Colors.green.shade600,
                  size: 18.w,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDcNoField(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "DC No",
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: isTablet ? 56.h : 52.h,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  color: Colors.orange.shade600,
                  size: 18.w,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _dcNoController,
                  readOnly: true,
                  style: GoogleFonts.dmSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: "Click camera to scan DC Number",
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      color: Colors.grey[500],
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 8.w),
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.orange.shade700,
                      size: 20.w,
                    ),
                  ),
                  onPressed: () => openMobileScanner(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDcDateField(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "DC Date",
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: isTablet ? 56.h : 52.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextFormField(
            controller: _dcDateController,
            readOnly: true,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: "DC Date",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 13.sp,
                color: Colors.grey[500],
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.purple.shade600,
                  size: 18.w,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartyField(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Party",
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: isTablet ? 56.h : 52.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextFormField(
            controller: _partyController,
            readOnly: true,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: "Party Name",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 13.sp,
                color: Colors.grey[500],
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.business,
                  color: Colors.teal.shade600,
                  size: 18.w,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDelQtyField(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Delivery Quantity",
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: isTablet ? 56.h : 52.h,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isEditable ? Colors.blue.shade300 : Colors.grey.shade300,
              width: isEditable ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.inventory,
                  color: Colors.red.shade600,
                  size: 18.w,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _delQtyController,
                  readOnly: !isEditable,
                  style: GoogleFonts.dmSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter Quantity",
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      color: Colors.grey[500],
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 8.w),
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: isEditable
                          ? Colors.green.shade100
                          : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      isEditable ? Icons.check : Icons.edit,
                      color: isEditable
                          ? Colors.green.shade700
                          : Colors.blue.shade700,
                      size: 20.w,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isEditable = !isEditable;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStmUserField(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "System User",
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: isTablet ? 56.h : 52.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextFormField(
            initialValue: deviceId,
            readOnly: true,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: "System User ID",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 13.sp,
                color: Colors.grey[500],
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.desktop_mac,
                  color: Colors.indigo.shade600,
                  size: 18.w,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isTablet, bool isLargeScreen) {
    return GestureDetector(
      onTap: () {
        MobileDocument(context);
      },
      child: Container(
        height: isTablet ? 56.h : 50.h,
        width: isLargeScreen ? (width / 3).w : (width / 2).w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.green.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Submit",
            style: GoogleFonts.dmSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

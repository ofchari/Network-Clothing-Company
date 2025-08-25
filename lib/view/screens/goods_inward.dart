import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:permission_handler/permission_handler.dart';
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
  List<Map<String, dynamic>> allParties = [];
  bool isLoadingParties = false;
  bool showPartyDropdown = false;

  // Add these new variables for IDPRTC printer
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  BluetoothCharacteristic? writeCharacteristic;
  // 1. ADD THESE VARIABLES (after existing variables around line 40)
  bool isScanning = false;
  bool isConnecting = false;

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
    fetchDocumentsByCategory();
    // ADD THIS LINE:
    initBluetooth();
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

  ///  Get Api's method for Doc Id's ///
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

    // PRINTER VALIDATION - Check if printer is connected
    if (selectedDevice == null || writeCharacteristic == null) {
      Get.snackbar(
        "Printer Required",
        "Please select and connect to a printer before submitting the document.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      setState(() {
        isLoading = false;
      });

      // Show printer selection dialog
      showPrinterSelectionDialog();
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

        final responseJson = json.decode(response.body);
        final String gateInMasId =
            responseJson["GATEINMASID"]?.toString() ?? postedDocId;
        final String createdOn =
            responseJson["CREATEDON"]?.toString() ?? formattedDateTime;

        // Print barcode using connected IDPRTC printer
        _printIDPRTCBarcode(gateInMasId, postedDocId, createdOn)
            .catchError((e) {
          Get.snackbar(
            "Print Error",
            "Document saved successfully but failed to print barcode: $e",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        });

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

  // Add IDPRTC printer initialization
  Future<void> initBluetooth() async {
    try {
      // Check if Bluetooth is available
      if (await FlutterBluePlus.isAvailable == false) {
        debugPrint("Bluetooth not available on this device");
        return;
      }

      // Request permissions
      await Permission.bluetoothScan.request();
      await Permission.bluetoothConnect.request();
      await Permission.locationWhenInUse.request();

      if (await Permission.bluetoothScan.isGranted &&
          await Permission.bluetoothConnect.isGranted &&
          await Permission.locationWhenInUse.isGranted) {
        // Start scanning
        setState(() {
          isScanning = true;
        });

        FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

        FlutterBluePlus.scanResults.listen((results) {
          for (ScanResult r in results) {
            if (!devices.contains(r.device) && r.device.name.isNotEmpty) {
              setState(() {
                devices.add(r.device);
              });
            }
          }
        });

        // Stop scanning after timeout
        await Future.delayed(const Duration(seconds: 10));
        FlutterBluePlus.stopScan();
        setState(() {
          isScanning = false;
        });
      } else {
        debugPrint("Bluetooth permissions not granted");
      }
    } catch (e) {
      debugPrint("Error initializing Bluetooth: $e");
      setState(() {
        isScanning = false;
      });
    }
  }

// 5. REPLACE the existing connectToDevice method:
  Future<void> connectToDevice(BluetoothDevice device) async {
    setState(() {
      isConnecting = true;
    });

    try {
      await FlutterBluePlus.stopScan();

      // Disconnect if already connected
      try {
        await device.disconnect();
      } catch (_) {}

      await Future.delayed(const Duration(seconds: 1));

      // Connect to device
      await device.connect(autoConnect: false);

      setState(() {
        selectedDevice = device;
      });

      // Discover services and find write characteristic
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var c in service.characteristics) {
          if (c.properties.write) {
            setState(() {
              writeCharacteristic = c;
            });
            debugPrint("Found write characteristic: ${c.uuid}");
            break;
          }
        }
        if (writeCharacteristic != null) break;
      }

      if (writeCharacteristic != null) {
        Get.snackbar(
          "Success",
          "Connected to ${device.name}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Connection error: $e");
      Get.snackbar(
        "Error",
        "Failed to connect to ${device.name}: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

// 6. ADD this new method to show printer selection dialog:
  void showPrinterSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Bluetooth Printer'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              if (selectedDevice != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Connected: ${selectedDevice!.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Available Devices:'),
                  ElevatedButton.icon(
                    onPressed: isScanning ? null : initBluetooth,
                    icon: isScanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    label: Text(isScanning ? 'Scanning...' : 'Scan'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: devices.isEmpty
                    ? const Center(
                        child: Text('No devices found. Tap Scan to search.'))
                    : ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          final isConnected = selectedDevice?.id == device.id;

                          return ListTile(
                            leading: Icon(
                              Icons.print,
                              color: isConnected ? Colors.green : Colors.grey,
                            ),
                            title: Text(
                              device.name.isNotEmpty
                                  ? device.name
                                  : 'Unknown Device',
                              style: TextStyle(
                                fontWeight: isConnected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(device.id.toString()),
                            trailing: isConnecting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : isConnected
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : const Icon(Icons.arrow_forward_ios),
                            onTap: isConnecting
                                ? null
                                : () => connectToDevice(device),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Function to generate barcode as ZPL command with IDPRTC printer ///
  String generateBarcodeZPL(String data) {
    // Generate ZPL barcode command for the gateInMasId
    return '''
^XA
^FO50,50
^BY2,3,100
^BCN,100,Y,N,N
^FD$data^FS
^XZ
''';
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

  void showBarcodeDialog(BuildContext context, String gateInMasId,
      String createdOn, String docId) {
    if (gateInMasId.isEmpty) {
      print("Error: Empty GATEINMASID for barcode");
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
              child: Center(
                child: Text(
                  gateInMasId, // Show the barcode data as text
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              docId, // Display DOCID below
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
            onPressed: () => _printIDPRTCBarcode(gateInMasId, docId, createdOn),
            icon: const Icon(Icons.print),
            label: const Text("Print"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Replace PDF printing with IDPRTC ZPL printing
  Future<void> _printIDPRTCBarcode(
      String barcodeData, String docId, String createdOn) async {
    if (selectedDevice == null || writeCharacteristic == null) {
      Get.snackbar(
        "Error",
        "Printer not connected. Please connect to a Bluetooth printer first.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint("Printer not connected");
      return;
    }

    try {
      // Parse UTC time and convert to IST (UTC +5:30)
      final parsedUtc = DateTime.parse(createdOn);
      final istTime = parsedUtc.add(const Duration(hours: 5, minutes: 30));

      final formattedDate =
          "${istTime.day.toString().padLeft(2, '0')}-${istTime.month.toString().padLeft(2, '0')}-${istTime.year} "
          "${istTime.hour.toString().padLeft(2, '0')}:${istTime.minute.toString().padLeft(2, '0')}:${istTime.second.toString().padLeft(2, '0')}";

      final String zplCommand = '''
^XA
^MMT
^PW800
^LL350
^LS0

~SD15
^FO50,30
^BY3,3,100
^BCN,100,Y,N,N
^FD$barcodeData^FS

^FO50,160
^A0N,22,22
^FD$formattedDate^FS

^FO50,200
^A0N,22,22
^FD$docId^FS

^FO450,30
^BY3,3,100
^BCN,100,Y,N,N
^FD$barcodeData^FS

^FO450,160
^A0N,22,22
^FD$formattedDate^FS

^FO450,200
^A0N,22,22
^FD$docId^FS

^XZ
''';

      debugPrint("ZPL Command: $zplCommand");
      await writeDataInChunks(utf8.encode(zplCommand), chunkSize: 64);
      debugPrint("Barcode sent to printer");

      Get.snackbar(
        "Success",
        "Barcode sent to printer successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to print barcode: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint("Print error: $e");
    }
  }

  Future<void> writeDataInChunks(List<int> data,
      {required int chunkSize}) async {
    for (int i = 0; i < data.length; i += 20) {
      final chunk =
          data.sublist(i, i + 20 > data.length ? data.length : i + 20);
      await writeCharacteristic!.write(chunk, withoutResponse: true);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  /// Get documents based on selected category and order type ///
  Future<void> fetchDocumentsByCategory() async {
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

    // Convert category to API parameter
    String ptype = '';
    switch (selectedCategory.toLowerCase()) {
      case 'yarn':
        ptype = 'yarn';
        break;
      case 'fabric':
        ptype = 'fabric';
        break;
      case 'accessories':
        ptype = 'accessories';
        break;
      case 'garments':
        ptype = 'garments';
        break;
      case 'general':
        ptype = 'general';
        break;
      case 'others':
        ptype = 'others';
        break;
      default:
        ptype = 'others';
    }

    // Convert order type to API parameter
    String dctype =
        selectedOrderType == 'Process Order' ? 'process' : 'purchase';

    final String url =
        'http://$serverIp:$port/get-documents?ptype=$ptype&dctype=$dctype';
    debugPrint('Fetching documents from URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var rawData = response.body.trim();
        print('Raw Response: ${response.body}');

        try {
          final data = json.decode(rawData);
          if (data is List && data.isNotEmpty) {
            setState(() {
              docIds = List<Map<String, dynamic>>.from(data);
              filteredDocIds = docIds;
              isLoading = false;
            });
            debugPrint(
                'Fetched ${docIds.length} documents for category: $selectedCategory, type: $selectedOrderType');

            // Show success message
            Get.snackbar(
              "Success",
              "Found ${docIds.length} documents for $selectedCategory ($selectedOrderType)",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else {
            debugPrint(
                'No documents found for the selected category and order type');
            setState(() {
              docIds = [];
              filteredDocIds = [];
              isLoading = false;
            });

            // Show info message
            Get.snackbar(
              "Info",
              "No documents found for $selectedCategory ($selectedOrderType)",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        } catch (jsonError) {
          debugPrint('JSON Parsing Error: $jsonError');
          setState(() {
            isLoading = false;
          });

          Get.snackbar(
            "Error",
            "Failed to parse response data",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        debugPrint(
            'Failed to fetch documents. Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
        setState(() {
          isLoading = false;
        });

        Get.snackbar(
          "Error",
          "Failed to fetch documents. Status: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (networkError) {
      debugPrint('Network Error: $networkError');
      setState(() {
        isLoading = false;
      });

      Get.snackbar(
        "Error",
        "Network error occurred: $networkError",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Fill form fields when document is selected from search ///
  Future<void> fillFormFromSelectedDocument(Map<String, dynamic> doc) async {
    setState(() {
      // Fill the form fields with the selected document data
      gstController.text = doc['GST']?.toString() ?? '';
      typeController.text =
          doc['PTYPE']?.toString() ?? selectedCategory.toLowerCase();
      party.text = doc['PARTYMASID']?.toString() ?? '';
      partyNameController.text = doc['PARTYID']?.toString() ?? '';

      // Set the search controller to show the selected DOCID
      searchController.text = doc['DOCID']?.toString() ?? '';

      // Clear the filtered results
      filteredDocIds = [];
    });

    debugPrint('Form filled with document: ${doc['DOCID']}');

    Get.snackbar(
      "Success",
      "Document details loaded: ${doc['DOCID']}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// API method to fetch parties based on GST
  Future<void> fetchPartiesByGST(String gst) async {
    setState(() {
      isLoadingParties = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('port') ?? '';

    if (serverIp.isEmpty || port.isEmpty) {
      Get.snackbar(
        "Error",
        "Server configuration missing",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isLoadingParties = false;
      });
      return;
    }

    try {
      String url;
      if (gst.isNotEmpty) {
        // First API - with specific GST
        url = 'http://$serverIp:$port/get_parties?gst=$gst';
      } else {
        // Second API - without GST to get all parties
        url = 'http://$serverIp:$port/get_parties?gst=';
      }

      final response = await http.get(Uri.parse(url));

      if (gst != gstController.text) {
        debugPrint('Ignoring stale GST response for $gst');
        setState(() {
          isLoadingParties = false;
        });
        return;
      }

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        if (gst.isNotEmpty) {
          // Handle specific GST response
          if (responseData.isNotEmpty) {
            if (responseData.length == 1) {
              // Single party: auto-fill
              final partyId = responseData[0]['PARTYID']?.toString() ?? '';
              final partynumbe =
                  responseData[0]['PARTYMASID']?.toString() ?? '';
              setState(() {
                partyNameController.text = partyId;
                party.text = partynumbe; // Also fill the party field
                showPartyDropdown = false;
              });
            } else {
              // Multiple parties: show dropdown
              setState(() {
                allParties = responseData.cast<Map<String, dynamic>>();
                filteredParties = List.from(allParties);
                showPartyDropdown = true;
                partyNameController.clear();
                party.clear();
              });
            }
            print(response.body);
          } else {
            // No parties found
            Get.snackbar(
              "Not Found",
              "No party found for this GST number",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            setState(() {
              partyNameController.clear();
              party.clear();
              showPartyDropdown = false;
            });
          }
        } else {
          // Handle all parties response
          setState(() {
            allParties = responseData.cast<Map<String, dynamic>>();
            if (partyNameController.text.isNotEmpty) {
              filteredParties = allParties.where((party) {
                final partyId =
                    party['PARTYID']?.toString().toLowerCase() ?? '';
                final partyGst = party['GST']?.toString().toLowerCase() ?? '';
                final searchText = partyNameController.text.toLowerCase();
                return partyId.contains(searchText) ||
                    partyGst.contains(searchText);
              }).toList();
              showPartyDropdown = filteredParties.isNotEmpty;
            } else {
              showPartyDropdown = false;
              filteredParties = [];
            }
          });
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch parties: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch parties: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoadingParties = false;
      });
    }
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

    // Responsive breakpoints
    bool isTablet = width > 600;
    bool isLargeScreen = width > 900;

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Subhead(
          text: "Gate Inward",
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
            vertical: 8.h,
          ),
          child: Column(
            children: [
              // Main content area - expandable
              Expanded(
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Container(
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
              ),

              SizedBox(height: 12.h),

              // Bottom section - fixed height
              _buildBottomSection(isTablet, isLargeScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveContent(bool isTablet, bool isLargeScreen) {
    // Adjust spacing based on screen size
    double sectionSpacing = isTablet ? 20.h : 16.h;
    double fieldSpacing = isTablet ? 12.h : 8.h;

    if (isLargeScreen) {
      // Two-column layout for large screens
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildDocIdSection(fieldSpacing),
                    SizedBox(height: sectionSpacing),
                    _buildCategoryButtons(isTablet),
                    SizedBox(height: sectionSpacing),
                    _buildOrderTypeRadio(isTablet),
                    SizedBox(height: sectionSpacing),
                    _buildGSTInputField(
                      label: 'GST Number',
                      controller: gstController,
                      icon: Icons.receipt_long,
                      iconColor: Colors.orange,
                      isCompact: true,
                    ),
                    SizedBox(height: sectionSpacing),
                    _buildSearchSection(fieldSpacing),
                    SizedBox(height: sectionSpacing),
                    _buildPartyNameFieldWithDropdown(
                      label: 'Party Name',
                      controller: partyNameController,
                      icon: Icons.business,
                      iconColor: Colors.teal,
                      isCompact: true,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: Column(
                  children: [
                    _buildInputField(
                      label: 'Type',
                      controller: typeController,
                      icon: Icons.merge_type,
                      iconColor: Colors.purple,
                      isCompact: true,
                    ),
                    SizedBox(height: sectionSpacing),
                    // _buildOrderTypeRadio(isTablet),
                    SizedBox(height: sectionSpacing),
                    _buildDcSection(fieldSpacing, isCompact: true),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sectionSpacing),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'GRN Quantity',
                  controller: delQty,
                  icon: Icons.inventory,
                  iconColor: Colors.brown,
                  keyboardType: TextInputType.number,
                  isCompact: true,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Single column layout for mobile and small tablets
      return Column(
        children: [
          _buildDocIdSection(fieldSpacing),
          SizedBox(height: sectionSpacing),
          _buildCategoryButtons(isTablet),
          SizedBox(height: sectionSpacing),
          _buildOrderTypeRadio(isTablet),
          SizedBox(height: sectionSpacing),
          _buildSearchSection(fieldSpacing),
          SizedBox(height: sectionSpacing),
          _buildGSTInputField(
            label: 'GST Number',
            controller: gstController,
            icon: Icons.receipt_long,
            iconColor: Colors.orange,
            isCompact: true,
          ),
          SizedBox(height: sectionSpacing),
          _buildPartyNameFieldWithDropdown(
            label: 'Party Name',
            controller: partyNameController,
            icon: Icons.business,
            iconColor: Colors.teal,
            isCompact: true,
          ),

          SizedBox(height: sectionSpacing),
          _buildInputField(
            label: 'Type',
            controller: typeController,
            icon: Icons.merge_type,
            iconColor: Colors.purple,
            isCompact: isTablet,
          ),
          SizedBox(height: sectionSpacing),
          // _buildOrderTypeRadio(isTablet),
          SizedBox(height: sectionSpacing),
          _buildDcSection(fieldSpacing, isCompact: isTablet),
          SizedBox(height: sectionSpacing),
          _buildInputField(
            label: 'GRN Quantity',
            controller: delQty,
            icon: Icons.inventory,
            iconColor: Colors.brown,
            keyboardType: TextInputType.number,
            isCompact: isTablet,
          ),
        ],
      );
    }
  }

  // Add these variables to your class
  String selectedCategory = '';
  String selectedOrderType = 'Process Order';

  /// Updated category buttons with auto-fetch ///
  Widget _buildCategoryButtons(bool isTablet) {
    final categories = [
      {
        'name': 'Yarn',
        'icon': Icons.settings_input_composite,
        'color': Colors.deepOrange
      },
      {'name': 'Fabric', 'icon': Icons.waves, 'color': Colors.teal},
      {'name': 'accessories', 'icon': Icons.extension, 'color': Colors.purple},
      {'name': 'garment', 'icon': Icons.checkroom, 'color': Colors.indigo},
      {'name': 'general', 'icon': Icons.inventory_2, 'color': Colors.brown},
      {'name': 'Others', 'icon': Icons.more_horiz, 'color': Colors.blueGrey},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: isTablet ? 3.5 : 3.2,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category['name'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category['name'] as String;
                  // Clear previous search results when category changes
                  docIds = [];
                  filteredDocIds = [];
                  searchController.clear();
                  // Clear form fields
                  gstController.clear();
                  party.clear();
                  partyNameController.clear();
                  typeController.text = selectedCategory.toLowerCase();
                });

                // Auto-fetch documents for the selected category
                fetchDocumentsByCategory();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (category['color'] as Color).withOpacity(0.1)
                      : Colors.grey.shade50,
                  border: Border.all(
                    color: isSelected
                        ? (category['color'] as Color)
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: isSelected
                          ? (category['color'] as Color)
                          : Colors.grey.shade600,
                      size: 18.w,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      category['name'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? (category['color'] as Color)
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Updated order type radio with auto-fetch ///
  Widget _buildOrderTypeRadio(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Type',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
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
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            child: Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      'Process Order',
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    value: 'Process Order',
                    groupValue: selectedOrderType,
                    onChanged: (value) {
                      setState(() {
                        selectedOrderType = value!;
                        // Clear previous search results when order type changes
                        docIds = [];
                        filteredDocIds = [];
                        searchController.clear();
                        // Clear form fields
                        gstController.clear();
                        typeController.clear();
                        party.clear();
                        partyNameController.clear();
                      });

                      // Auto-fetch documents if category is selected
                      if (selectedCategory.isNotEmpty) {
                        fetchDocumentsByCategory();
                      }
                    },
                    activeColor: Colors.blue.shade600,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      'Purchase Order',
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    value: 'Purchase Order',
                    groupValue: selectedOrderType,
                    onChanged: (value) {
                      setState(() {
                        selectedOrderType = value!;
                        // Clear previous search results when order type changes
                        docIds = [];
                        filteredDocIds = [];
                        searchController.clear();
                        // Clear form fields
                        gstController.clear();
                        typeController.clear();
                        party.clear();
                        partyNameController.clear();
                      });

                      // Auto-fetch documents if category is selected
                      if (selectedCategory.isNotEmpty) {
                        fetchDocumentsByCategory();
                      }
                    },
                    activeColor: Colors.blue.shade600,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocIdSection(double fieldSpacing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Document ID',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextFormField(
              controller: docIdController,
              style: GoogleFonts.dmSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                // hintText: 'Enter Document ID',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
                prefixIcon: Container(
                  margin: EdgeInsets.all(12.w),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.security_update_good_rounded,
                    color: Colors.blue.shade600,
                    size: 20.w,
                  ),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Modified search section with category-based fetching ///
  Widget _buildSearchSection(double fieldSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PO/DC Number',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: Colors.grey[800],
              ),
            ),
            // Fetch button
            GestureDetector(
              onTap: () {
                if (selectedCategory.isEmpty) {
                  Get.snackbar(
                    "Error",
                    "Please select a category first",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                fetchDocumentsByCategory();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade300),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Colors.blue.shade600,
                      size: 16.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Fetch',
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: fieldSpacing),
        Container(
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
          child: TextFormField(
            controller: searchController,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.search,
                  color: Colors.green.shade600,
                  size: 20.w,
                ),
              ),
              hintText: "Search PO/DC Number",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              border: InputBorder.none,
            ),
            onChanged: (text) {
              setState(() {
                if (text.isEmpty) {
                  filteredDocIds = [];
                } else {
                  filteredDocIds = docIds.where((doc) {
                    final docId = doc['DOCID']?.toString() ?? '';
                    return docId.toLowerCase().contains(text.toLowerCase());
                  }).toList();
                }
              });
            },
          ),
        ),

        // Search Results Dropdown
        if (searchController.text.isNotEmpty && filteredDocIds.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            constraints: BoxConstraints(maxHeight: 150.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredDocIds.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == filteredDocIds.length) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final doc = filteredDocIds[index];
                return InkWell(
                  onTap: () async {
                    // Fill form with selected document data
                    await fillFormFromSelectedDocument(doc);
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      border: index != filteredDocIds.length - 1
                          ? Border(
                              bottom: BorderSide(color: Colors.grey.shade200))
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc['DOCID']?.toString() ?? '',
                          style: GoogleFonts.dmSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (doc['PARTYID'] != null)
                          Text(
                            doc['PARTYID'].toString(),
                            style: GoogleFonts.dmSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // Show message when no documents are available
        if (docIds.isEmpty && !isLoading && selectedCategory.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade200),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange.shade600,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'No documents found for $selectedCategory ($selectedOrderType). Click "Fetch" to reload.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDcSection(double fieldSpacing, {bool isCompact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DC Number & Date',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: fieldSpacing),
        Row(
          children: [
            Expanded(
              child: Container(
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
                child: TextFormField(
                  controller: dcnumber,
                  style: GoogleFonts.dmSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: "DC Number",
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 14.sp,
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
                        Icons.assignment,
                        color: Colors.indigo.shade600,
                        size: 18.w,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: isCompact ? 14.h : 16.h, horizontal: 16.w),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Container(
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
                child: TextFormField(
                  controller: _dateController,
                  readOnly: true,
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
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: "Select Date",
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                    prefixIcon: Container(
                      margin: EdgeInsets.all(12.w),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: Colors.red.shade600,
                        size: 18.w,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: isCompact ? 14.h : 16.h, horizontal: 16.w),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomSection(bool isTablet, bool isLargeScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Printer selection
        Container(
          height: isTablet ? 60.h : 55.h,
          decoration: BoxDecoration(
            color: selectedDevice != null
                ? Colors.green.shade50
                : Colors.grey.shade50,
            border: Border.all(
              color: selectedDevice != null
                  ? Colors.green.shade300
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: selectedDevice != null
                    ? Colors.green.shade100
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.print,
                color: selectedDevice != null
                    ? Colors.green.shade700
                    : Colors.grey.shade600,
                size: 20.w,
              ),
            ),
            title: Text(
              selectedDevice != null
                  ? 'Connected: ${selectedDevice!.name}'
                  : 'No Printer Selected',
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: selectedDevice != null
                    ? Colors.green.shade800
                    : Colors.grey.shade700,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: Colors.grey.shade600,
            ),
            onTap: showPrinterSelectionDialog,
          ),
        ),

        SizedBox(height: 16.h),

        // Submit button
        GestureDetector(
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
        ),
      ],
    );
  }

  /// Updated GST input field with auto-fetch functionality
  Widget _buildGSTInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    bool isCompact = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: isCompact ? 6.h : 8.h),
        Container(
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
          child: TextFormField(
            controller: controller,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: "Enter $label",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor.withOpacity(0.8),
                  size: 20.w,
                ),
              ),
              suffixIcon: isLoadingParties
                  ? Container(
                      margin: EdgeInsets.all(12.w),
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(
                  vertical: isCompact ? 14.h : 16.h, horizontal: 16.w),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              // Add debouncing to avoid too many API calls
              Timer? debounceTimer;
              if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
              debounceTimer = Timer(const Duration(milliseconds: 800), () {
                if (value.isNotEmpty) {
                  fetchPartiesByGST(value);
                } else {
                  // When GST is cleared, show all parties
                  fetchPartiesByGST('');
                }
              });
            },
          ),
        ),
      ],
    );
  }

  List<dynamic> filteredParties = [];

  /// Updated Party Name field with dropdown
  Widget _buildPartyNameFieldWithDropdown({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    bool isCompact = false,
  }) {
    // Add import for Timer at the top of your file: import 'dart:async';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: isCompact ? 6.h : 8.h),
        Container(
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
          child: TextFormField(
            controller: controller,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: "Enter $label or select from dropdown",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor.withOpacity(0.8),
                  size: 20.w,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                  vertical: isCompact ? 14.h : 16.h, horizontal: 16.w),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              // Filter parties based on search text
              setState(() {
                if (value.isNotEmpty) {
                  showPartyDropdown = true;
                  // Filter parties that contain the search text (case insensitive)
                  filteredParties = allParties.where((party) {
                    final partyId =
                        party['PARTYID']?.toString().toLowerCase() ?? '';
                    final gst = party['GST']?.toString().toLowerCase() ?? '';
                    final searchText = value.toLowerCase();

                    return partyId.contains(searchText) ||
                        gst.contains(searchText);
                  }).toList();
                } else {
                  showPartyDropdown = false;
                  filteredParties = [];
                }
              });
            },
            onTap: () {
              // If GST field is empty, fetch all parties when user taps
              if (gstController.text.isEmpty && allParties.isEmpty) {
                fetchPartiesByGST('');
              }

              // Show dropdown if we have parties and field is not empty
              if (allParties.isNotEmpty && controller.text.isNotEmpty) {
                setState(() {
                  showPartyDropdown = true;
                  // Filter based on current text
                  filteredParties = allParties.where((party) {
                    final partyId =
                        party['PARTYID']?.toString().toLowerCase() ?? '';
                    final gst = party['GST']?.toString().toLowerCase() ?? '';
                    final searchText = controller.text.toLowerCase();

                    return partyId.contains(searchText) ||
                        gst.contains(searchText);
                  }).toList();
                });
              }
            },
          ),
        ),

        // Party Dropdown - Using filteredParties instead of allParties
        if (showPartyDropdown && filteredParties.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Party (${filteredParties.length})',
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showPartyDropdown = false;
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 16.w,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Party List - Using filteredParties
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredParties.length,
                    itemBuilder: (context, index) {
                      final party = filteredParties[index];
                      final partyId = party['PARTYID']?.toString() ?? '';
                      final gst = party['GST']?.toString() ?? '';

                      return InkWell(
                        onTap: () {
                          setState(() {
                            partyNameController.text = partyId;
                            this.party.text =
                                party['PARTYMASID']?.toString() ?? '';
                            gstController.text = gst;
                            showPartyDropdown = false;
                          });

                          Get.snackbar(
                            "Selected",
                            "Party selected: $partyId",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: Duration(seconds: 2),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                            border: index != filteredParties.length - 1
                                ? Border(
                                    bottom:
                                        BorderSide(color: Colors.grey.shade200))
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partyId,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              if (gst.isNotEmpty)
                                Text(
                                  'GST: $gst',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

// Helper method for input fields
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    TextInputType? keyboardType,
    bool isCompact = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: isCompact ? 6.h : 8.h),
        Container(
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
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: "Enter $label",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor.withOpacity(0.8),
                  size: 20.w,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                  vertical: isCompact ? 14.h : 16.h, horizontal: 16.w),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

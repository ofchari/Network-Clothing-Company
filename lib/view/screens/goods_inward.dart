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
      debugPrint('Error incrementing DocID: Blockquotee');
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

        final responseJson = json.decode(response.body);
        final String gateInMasId =
            responseJson["GATEINMASID"]?.toString() ?? postedDocId;
        final String createdOn =
            responseJson["CREATEDON"]?.toString() ?? formattedDateTime;

        // Automatically print barcode using IDPRTC printer instead of showing dialog
        if (selectedDevice != null && writeCharacteristic != null) {
          _printIDPRTCBarcode(gateInMasId, postedDocId, createdOn)
              .catchError((e) {
            Get.snackbar(
              "Error",
              "Failed to print barcode: $e",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          });
        } else {
          // Show barcode dialog if printer not connected
          showBarcodeDialog(context, gateInMasId, createdOn, postedDocId);
        }

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
                    _buildSearchSection(fieldSpacing),
                    SizedBox(height: sectionSpacing),
                    _buildInputField(
                      label: 'GST Number',
                      controller: gstController,
                      icon: Icons.receipt_long,
                      iconColor: Colors.orange,
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
                    _buildInputField(
                      label: 'Party Name',
                      controller: partyNameController,
                      icon: Icons.business,
                      iconColor: Colors.teal,
                      isCompact: true,
                    ),
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
          _buildSearchSection(fieldSpacing),
          SizedBox(height: sectionSpacing),
          _buildInputField(
            label: 'GST Number',
            controller: gstController,
            icon: Icons.receipt_long,
            iconColor: Colors.orange,
            isCompact: isTablet,
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
          _buildInputField(
            label: 'Party Name',
            controller: partyNameController,
            icon: Icons.business,
            iconColor: Colors.teal,
            isCompact: isTablet,
          ),
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

  Widget _buildDocIdSection(double fieldSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document ID',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: fieldSpacing),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextFormField(
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: docIdController.text,
              labelStyle: GoogleFonts.dmSans(
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
      ],
    );
  }

  Widget _buildSearchSection(double fieldSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PO/DC Number',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.grey[800],
          ),
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
                    searchController.text = doc['DOCID'];
                    await fetchDocDetails(doc['DOCID']);
                    setState(() {
                      filteredDocIds = [];
                    });
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
                    child: Text(
                      doc['DOCID'],
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              },
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
                colors: [Colors.blue.shade600, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
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

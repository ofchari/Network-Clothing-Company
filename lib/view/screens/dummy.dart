import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ncc/view/widgets/buttons.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:ncc/view/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class Dummy extends StatefulWidget {
  const Dummy({super.key});

  @override
  State<Dummy> createState() => _DummyState();
}

class _DummyState extends State<Dummy> {
  late double height;
  late double width;
  late String usCode;
  late int orderNumber;
  String deviceId = '';

  final List<Map<String, dynamic>> docIds = [];
  final List<Map<String, dynamic>> filteredDocIds = [];
  String? selectedDocId;
  bool isLoading = false;
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController partyNameController = TextEditingController();
  final _dateController = TextEditingController();
  String formattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());

  int currentPage = 1; // Current page for pagination
  final int perPage = 500; // Items per page
  bool hasMore = true; // Flag to indicate if more data is available

  // Get the current date and time
  DateTime now = DateTime.now();

  // Convert to ISO 8601 string (common format for APIs)
  String currentTime = DateFormat('HH.mm.ss').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    fetchDeviceId();
    fetchDocIds(); // Initial fetch
    scrollController.addListener(_scrollListener);
    searchController.addListener(_onSearchChanged);
  }

  /// Scroll Listener for Pagination
  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMore &&
        searchController.text.isEmpty) {
      fetchDocIds(); // Fetch more data when scrolled near the bottom
    }
  }

  /// Search Controller Listener
  void _onSearchChanged() {
    filterDocIds(searchController.text);
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

  /// Get API's method for Doc Id's ///
  Future<void> fetchDocIds() async {
    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('port') ?? '';

    if (serverIp.isEmpty || port.isEmpty) {
      debugPrint('Error: Server IP or port is not configured.');
      return;
    }

    final String url =
        'http://$serverIp:$port/db/gate_gst_get_api.php?page=$currentPage&per_page=$perPage';
    debugPrint('Fetching URL: $url');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            docIds.addAll(List<Map<String, dynamic>>.from(data));
            filterDocIds(searchController.text); // Update filtered list
            currentPage++;
            if (data.length < perPage) {
              hasMore = false; // No more data to fetch
            }
          });
        } else {
          debugPrint('Unexpected data format: $data');
          setState(() {
            hasMore = false;
          });
        }
      } else {
        debugPrint('Failed to fetch data. Status: ${response.statusCode}');
        setState(() {
          hasMore = false;
        });
      }
    } catch (error) {
      debugPrint('Error fetching data: $error');
      setState(() {
        hasMore = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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

  /// Load User Details ///
  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    usCode = prefs.getString('usCode') ?? 'UNKNOWN';
    orderNumber = prefs.getInt('orderNumber_$usCode') ?? 1; // Start from 1 for the user

    setState(() {});
  }

  /// Filter DOCIDs based on search query ///
  /// Filter DOCIDs based on search query
  void filterDocIds(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredDocIds.clear();
      });
    } else {
      setState(() {
        filteredDocIds.clear();
        filteredDocIds.addAll(docIds.where((doc) =>
            doc['DOCID'].toString().toLowerCase().contains(query.toLowerCase())));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      if (width <= 450) {
        return _smallBuildLayout();
      } else {
        return const Center(
          child: Text("Please make sure your device is in portrait view"),
        );
      }
    });
  }

  Widget _smallBuildLayout() {
    /// Define Sizes ///
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
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '    Doc ID:',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 16),
              ),
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
                readOnly: true,
                // If you want it to be editable, remove readOnly
                style: GoogleFonts.dmSans(
                    textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black)),
                decoration: InputDecoration(
                    labelText: "$usCode/24/$orderNumber",
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
            SizedBox(height: 14.5.h),
            const Align(
                alignment: Alignment.topLeft,
                child: MyText(text: "     Po/Dc No ", weight: FontWeight.w500, color: Colors.black)),
            SizedBox(height: 7.5.h),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade500),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextFormField(
                controller: searchController,
                onChanged: filterDocIds,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade700),
                  hintText: "Type to search Po/Dc No",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade500),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Display Filtered List or Paginated List
            Expanded(
              child: searchController.text.isNotEmpty && filteredDocIds.isNotEmpty
                  ? _buildFilteredList()
                  : _buildPaginatedList(),
            ),

            SizedBox(height: 14.5.h),
            const Align(
                alignment: Alignment.topLeft,
                child: MyText(text: "     GST No ", weight: FontWeight.w500, color: Colors.black)),
            SizedBox(height: 7.5.h),
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
                    textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black)),
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
            SizedBox(height: 14.5.h),
            const Align(
                alignment: Alignment.topLeft,
                child: MyText(text: "     Type ", weight: FontWeight.w500, color: Colors.black)),
            SizedBox(height: 7.5.h),
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
                    textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black)),
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
                child: MyText(text: "     Party Name ", weight: FontWeight.w500, color: Colors.black)),
            SizedBox(height: 7.5.h),
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
                    textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black)),
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
            SizedBox(height: 14.5.h),
            const Align(
                alignment: Alignment.topLeft,
                child: MyText(text: "     Stm User ", weight: FontWeight.w500, color: Colors.black)),
            SizedBox(height: 7.5.h),
            Container(
              height: height / 15.2.h,
              width: width / 1.13.w,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade500),
                  borderRadius: BorderRadius.circular(6.r)),
              child: TextFormField(
                initialValue: deviceId,
                readOnly: true, // Assuming device ID should not be editable
                style: GoogleFonts.dmSans(
                    textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black)),
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
            SizedBox(height: 15.h),
            GestureDetector(
                onTap: () {
                  // Implement your submit logic here
                },
                child: Buttons(
                    height: height / 18.h,
                    width: width / 2.w,
                    radius: BorderRadius.circular(7),
                    color: Colors.blue,
                    text: "Submit")),
            SizedBox(height: 15.h),

       ] ),
    ),
    );
  }

  /// Build the Filtered ListView
  Widget _buildFilteredList() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListView.builder(
        itemCount: filteredDocIds.length,
        itemBuilder: (context, index) {
          final doc = filteredDocIds[index];
          return ListTile(
            title: Text(doc['DOCID']),
            onTap: () async {
              debugPrint('Selected DOCID: ${doc['DOCID']}');
              searchController.text = doc['DOCID'];
              filterDocIds(''); // Clear the filtered list after selection
              await fetchDocDetails(doc['DOCID']); // Fetch details for the selected DocID
            },
          );
        },
      ),
    );
  }

  /// Build the Paginated ListView
  Widget _buildPaginatedList() {
    return ListView.builder(
      controller: scrollController,
      itemCount: docIds.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == docIds.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final doc = docIds[index];
        return ListTile(
          title: Text(doc['DOCID']),
          onTap: () {
            debugPrint('Selected DOCID: ${doc['DOCID']}');
            // Handle selection, e.g., navigate to details or populate fields
          },
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    gstController.dispose();
    typeController.dispose();
    partyNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncc/view/screens/dashboard.dart';
import 'package:ncc/view/widgets/subhead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ncc/view/widgets/buttons.dart';
import 'package:http/http.dart' as http;

class FormIp extends StatefulWidget {
  const FormIp({super.key});

  @override
  State<FormIp> createState() => _FormIpState();
}

class _FormIpState extends State<FormIp> {
  late double height;
  late double width;

  final TextEditingController _serverIpController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final serverIp = prefs.getString('serverIp');
    final port = prefs.getString('port');
    final username = prefs.getString('username');

    if (serverIp != null && port != null && username != null) {
      // Auto-login if credentials exist
      _serverIpController.text = serverIp;
      _portController.text = port;
      _usernameController.text = username;
      Get.off(() => const Dashboard()); // Navigate to Dashboard, replacing current route
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Server Settings',
            style: GoogleFonts.figtree(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _serverIpController,
                  decoration: InputDecoration(
                    labelText: "Server IP",
                    labelStyle: GoogleFonts.figtree(
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: _portController,
                  decoration: InputDecoration(
                    labelText: "Port",
                    labelStyle: GoogleFonts.figtree(
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Success',
                  'Server settings updated',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              child: Text(
                'Save',
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
         /// Logout logic for sharepreferences ///
  Future<void> logout() async {
    try {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Clear all stored credentials
      await prefs.remove('serverIp');
      await prefs.remove('port');
      await prefs.remove('username');

      // Optional: Clear all preferences if you want to remove everything
      // await prefs.clear();

      // Show success message
      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear text controllers
      _serverIpController.clear();
      _portController.clear();
      _usernameController.clear();

      // Navigate back to login screen (FormIp)
      // Using Get.offAll() to remove all previous routes from the stack
      Get.offAll(() => const FormIp());

    } catch (e) {
      // Show error message if logout fails
      Get.snackbar(
        'Error',
        'Failed to logout: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  Future<void> _login() async {
    final serverIp = _serverIpController.text.trim();
    final port = _portController.text.trim();
    final username = _usernameController.text.trim();

    if (serverIp.isEmpty || port.isEmpty || username.isEmpty) {
      _showError("Please enter Server IP, Port, and Username");
      return;
    }

    final apiUrl = "http://$serverIp:$port/user_api";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> users = responseData['data'] ?? [];
        final userExists = users.any((user) =>
        (user['USERNAME'] as String).toLowerCase() == username.toLowerCase()
        );

        if (userExists) {
          // Find the USCODE for the user
          final user = users.firstWhere((user) =>
          (user['USERNAME'] as String).toLowerCase() == username.toLowerCase()
          );
          final usCode = user['USCODE'];

          // Store user credentials and USCODE
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('serverIp', serverIp);
          await prefs.setString('port', port);
          await prefs.setString('username', username);
          await prefs.setString('usCode', usCode);

          Get.off(() => const Dashboard()); // Navigate to Dashboard, replacing current route
        } else {
          _showError("Username not found in the database");
        }
      } else {
        _showError("Failed to connect. Status: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection Error: $e");
    }
  }


  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;

        if (width <= 1000) {
          return _smallBuildLayout();
        } else {
          return const Text("Please make sure your device is in portrait view");
        }
      },
    );
  }

  Widget _smallBuildLayout() {
    return Scaffold(
      backgroundColor: const Color(0xfff1f2f4),
      appBar: AppBar(
        backgroundColor: const Color(0xfff1f2f4),
        toolbarHeight: 70.h,
        title: const Subhead(
          text: "Login Form",
          weight: FontWeight.w500,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        width: width.w,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 60.h),
              Container(
                height: height / 3.h,
                width: width / 1.4.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/login.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: "Username",
                          labelStyle: GoogleFonts.figtree(
                            textStyle: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.blueGrey, size: 50),
                    onPressed: _showSettingsDialog,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: _login,
                child: Buttons(
                  height: height / 18.h,
                  width: width / 2.w,
                  radius: BorderRadius.circular(10.r),
                  color: Colors.blue,
                  text: "Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
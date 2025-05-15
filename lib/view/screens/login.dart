import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ncc/services/goods_Inward_api.dart';

import '../../model/json_model/Inward_get_json.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late double height;
  late double width;
  @override
  Widget build(BuildContext context) {
    /// Define Sizes //
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      body: SizedBox(
        width: width.w,
        child: Column(
          children: [
            SizedBox(
              height: 50.h,
            ),
            FutureBuilder(
                future: fetchInward(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  } else {
                    return Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              Data outs = snapshot.data![index];
                              // print("${outs.type}");
                              //   print("${outs.type}");
                              //   print("${outs.type}");
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 50.h,
                                  ),
                                  // Text(outs.type.toString()),
                                ],
                              );
                            }));
                  }
                })
          ],
        ),
      ),
    );
  }
}

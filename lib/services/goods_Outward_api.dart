import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;

import '../model/json_model/Outward_get_json.dart';

Future<List<Datum>> fetchOutward() async{
  final response = await http.get(Uri.parse("http://192.168.1.7:8080/db/get_api.php"));
  if(response.statusCode == 200){
    List<dynamic> outwards = jsonDecode(response.body)['data'];
    print(response.body);
    return outwards.map((e)=>Datum.fromJson(e)).toList();
  }
  else{
    throw Exception("Error status ${response.statusCode}");
  }
}


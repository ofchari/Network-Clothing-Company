import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/json_model/Inward_get_json.dart';

Future<List<Data>> fetchInward() async {
  final prefs = await SharedPreferences.getInstance();
  final serverIp = prefs.getString('serverIp') ?? '';
  final port = prefs.getString('port') ?? '';

  if (serverIp.isEmpty || port.isEmpty) {
    throw Exception("Server IP or Port not set");
  }

  final apiUrl = "http://$serverIp:$port/db/get_api.php";
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    List<dynamic> outwards = jsonDecode(response.body);
    return outwards.map((e) => Data.fromJson(e)).toList();
  } else {
    throw Exception("Error status ${response.statusCode}");
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ncc/model/json_model/outward_get_json.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Datumm>> fetchOutward() async {
  final prefs = await SharedPreferences.getInstance();
  final serverIp = prefs.getString('serverIp') ?? '';
  final port = prefs.getString('port') ?? '';
  final username = prefs.getString('username') ?? '';

  if (serverIp.isEmpty || port.isEmpty) {
    throw Exception("Server IP or Port not set");
  }

  final apiUrl = "http://$serverIp:$port/outward_get_api?username=$username";
  final response = await http.get(Uri.parse(apiUrl));
  print(response.body);
  print(response.statusCode);

  if (response.statusCode == 200) {
    List<dynamic> gateOut = jsonDecode(response.body);
    print(response.body);
    return gateOut.map((e) => Datumm.fromJson(e)).toList();
  } else {
    throw Exception("Error status ${response.statusCode}");
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

Future<List<User>> fetchUsers() async {
  final response = await http.get(Uri.parse('https://api.escuelajs.co/api/v1/users'));

  if (response.statusCode == 200) {
    List<dynamic> usersJson = json.decode(response.body);
    return usersJson.map((json) => User.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load users');
  }
}

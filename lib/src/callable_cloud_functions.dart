import 'dart:convert';

import 'package:http/browser_client.dart';

import 'auth_service.dart';

const _cloudFnUrl = 'https://us-central1-joint-45cb3.cloudfunctions.net';

Future<Map<String, dynamic>> callCloudFn(String fn, {data = const {}}) async {
  final client = new BrowserClient();
  final payload = json.encode({'data': data});
  final token = await AuthService.currentUser()?.getIdToken();
  final res = await client.post('$_cloudFnUrl/$fn',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8'
      },
      body: payload);
  if (res.statusCode != 200) {
    throw Exception(
        'request returned code ${res.statusCode}, body: ${res.body}');
  }
  return json.decode(res.body);
}

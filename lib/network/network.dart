import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myfirstapp_flutter/model/model_authentikasi.dart';

class Network {
  static String _host = "udakita.com";

  Future<ModelAuthentinkasi> daftarCostumer(
      String nama, String email, String password, String phone) async {
    final url = Uri.http(_host, "serverojol/api/daftar");
    final response = await http.post(url, body: {
      "nama": nama,
      "email": email,
      "password": password,
      "phone": phone
    });
    if (response.statusCode == 200) {
      ModelAuthentinkasi responRegister =
          ModelAuthentinkasi.fromJson(jsonDecode(response.body));
      return responRegister;
    } else {
      return null;
    }
  }
}

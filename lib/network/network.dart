import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myfirstapp_flutter/model/model_authentikasi.dart';
import 'package:myfirstapp_flutter/model/model_insertbooking.dart';

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

  Future<ModelAuthentinkasi> loginCostumer(
      String email, String password, String device) async {
    final url = Uri.http(_host, "serverojol/api/login");
    final response = await http.post(url,
        body: {"device": device, "f_email": email, "f_password": password});
    if (response.statusCode == 200) {
      ModelAuthentinkasi responRegister =
          ModelAuthentinkasi.fromJson(jsonDecode(response.body));
      return responRegister;
    } else {
      return null;
    }
  }

  Future<ModelInsertBooking> insertBooking(
    idUser,
    latAwal,
    lngAwal,
    lokasiAwal,
    latAkhir,
    lngAkhir,
    lokasiAkhir,
    catatan,
    jarak,
    token,
    device,
  ) async {
     final url = Uri.http(_host, "serverojol/api/insert_booking");
    final response = await http.post(url, body: {
      "f_idUser": idUser,
      "f_latAwal": latAwal,
      "f_awal": lokasiAwal,
       "f_latAkhir": latAkhir,
      "f_lngAkhir": lngAkhir,
      "f_akhir": lokasiAkhir,
       "f_catatan": catatan,
      "f_jarak": jarak,
      "f_lngAwal": lngAwal,
       "f_token": token,
      "f_device": device
    });
       if (response.statusCode == 200) {
      ModelInsertBooking responInsertBooking =
          ModelInsertBooking.fromJson(jsonDecode(response.body));
      return responInsertBooking;
    } else {
      return null;
    }
  }
}

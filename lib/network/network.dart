import 'dart:convert';

import 'package:driverojol/model/model_driver.dart';
import 'package:driverojol/model/model_history.dart';
import 'package:driverojol/model/model_waitingdriver.dart';
import 'package:http/http.dart' as http;
import 'package:driverojol/model/model_authentikasi.dart';
import 'package:driverojol/model/model_insertbooking.dart';

class Network {
  static String _host = "udakita.com";

  Future<ModelAuthentinkasi> daftarCostumer(
      String nama, String email, String password, String phone) async {
    final url = Uri.http(_host, "serverojol/api/daftar/3");
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
    final url = Uri.http(_host, "serverojol/api/login_driver");
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

  Future<ModelWaitingDriver> checkBooking(idBooking) async {
    final url = Uri.http(_host, "serverojol/api/checkBooking");
    final response = await http.post(url, body: {"idbooking": idBooking});
    if (response.statusCode == 200) {
      ModelWaitingDriver responCheckBooking =
          ModelWaitingDriver.fromJson(jsonDecode(response.body));
      return responCheckBooking;
    } else {
      return null;
    }
  }

  Future<ModelWaitingDriver> cancelBooking(idBooking, token, device) async {
    final url = Uri.http(_host, "serverojol/api/cancel_booking");
    final response = await http.post(url,
        body: {"idbooking": idBooking, "f_token": token, "f_device": device});
    if (response.statusCode == 200) {
      ModelWaitingDriver responCheckBooking =
          ModelWaitingDriver.fromJson(jsonDecode(response.body));
      return responCheckBooking;
    } else {
      return null;
    }
  }

  Future<ModelDriver> getDetailDriver(idDriver) async {
    final url = Uri.http(_host, "serverojol/api/get_driver");
    final response = await http.post(url, body: {"f_iddriver": idDriver});
    if (response.statusCode == 200) {
      ModelDriver responseDriver =
          ModelDriver.fromJson(jsonDecode(response.body));
      return responseDriver;
    } else {
      return null;
    }
  }

  Future<ModelHistory> getHistory(idUser, status, token, device) async {
    final url = Uri.http(_host, "serverojol/api/get_booking");
    final response = await http.post(url, body: {
      "f_idUser": idUser,
      "status": status,
      "f_token": token,
      "f_device": device
    });
    if (response.statusCode == 200) {
      ModelHistory responseHistory =
          ModelHistory.fromJson(jsonDecode(response.body));
      return responseHistory;
    } else {
      return null;
    }
  }

  Future<ModelHistory> registerFcm(idUser, fcm) async {
    final url = Uri.http(_host, "serverojol/api/registerGcm");
    final response = await http.post(url, body: {
      "f_idUser": idUser,
      "f_gcm": fcm
    });
    if (response.statusCode == 200) {
      ModelHistory responsefcm =
          ModelHistory.fromJson(jsonDecode(response.body));
      return responsefcm;
    } else {
      return null;
    }
  }
}

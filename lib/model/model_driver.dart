class ModelDriver {
  String result;
  String msg;
  List<Data> data;

  ModelDriver({this.result, this.msg, this.data});

  ModelDriver.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String idTracking;
  String trackingWaktu;
  String trackingDriver;
  String trackingLat;
  String trackingLng;
  String trackingStatus;
  String idUser;
  String userNama;
  String userEmail;
  String userPassword;
  String userHp;
  Null userAvatar;
  String userGcm;
  String userRegister;
  String userLevel;
  String userStatus;

  Data(
      {this.idTracking,
      this.trackingWaktu,
      this.trackingDriver,
      this.trackingLat,
      this.trackingLng,
      this.trackingStatus,
      this.idUser,
      this.userNama,
      this.userEmail,
      this.userPassword,
      this.userHp,
      this.userAvatar,
      this.userGcm,
      this.userRegister,
      this.userLevel,
      this.userStatus});

  Data.fromJson(Map<String, dynamic> json) {
    idTracking = json['id_tracking'];
    trackingWaktu = json['tracking_waktu'];
    trackingDriver = json['tracking_driver'];
    trackingLat = json['tracking_lat'];
    trackingLng = json['tracking_lng'];
    trackingStatus = json['tracking_status'];
    idUser = json['id_user'];
    userNama = json['user_nama'];
    userEmail = json['user_email'];
    userPassword = json['user_password'];
    userHp = json['user_hp'];
    userAvatar = json['user_avatar'];
    userGcm = json['user_gcm'];
    userRegister = json['user_register'];
    userLevel = json['user_level'];
    userStatus = json['user_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_tracking'] = this.idTracking;
    data['tracking_waktu'] = this.trackingWaktu;
    data['tracking_driver'] = this.trackingDriver;
    data['tracking_lat'] = this.trackingLat;
    data['tracking_lng'] = this.trackingLng;
    data['tracking_status'] = this.trackingStatus;
    data['id_user'] = this.idUser;
    data['user_nama'] = this.userNama;
    data['user_email'] = this.userEmail;
    data['user_password'] = this.userPassword;
    data['user_hp'] = this.userHp;
    data['user_avatar'] = this.userAvatar;
    data['user_gcm'] = this.userGcm;
    data['user_register'] = this.userRegister;
    data['user_level'] = this.userLevel;
    data['user_status'] = this.userStatus;
    return data;
  }
}

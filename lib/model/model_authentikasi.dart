class ModelAuthentinkasi {
  String result;
  String token;
  Data data;
  String msg;
  String idUser;

  ModelAuthentinkasi(
      {this.result, this.token, this.data, this.msg, this.idUser});

  ModelAuthentinkasi.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    token = json['token'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    msg = json['msg'];
    idUser = json['idUser'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    data['token'] = this.token;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['msg'] = this.msg;
    data['idUser'] = this.idUser;
    return data;
  }
}

class Data {
  String idUser;
  String userNama;
  String userEmail;
  String userPassword;
  String userHp;
  Null userAvatar;
  Null userGcm;
  String userRegister;
  String userLevel;
  String userStatus;

  Data(
      {this.idUser,
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

class ModelInsertBooking {
  String result;
  String msg;
  int tarif;
  String waktu;
  int idBooking;

  ModelInsertBooking(
      {this.result, this.msg, this.tarif, this.waktu, this.idBooking});

  ModelInsertBooking.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    msg = json['msg'];
    tarif = json['tarif'];
    waktu = json['waktu'];
    idBooking = json['id_booking'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    data['msg'] = this.msg;
    data['tarif'] = this.tarif;
    data['waktu'] = this.waktu;
    data['id_booking'] = this.idBooking;
    return data;
  }
}

class ModelWaitingDriver {
  String result;
  String msg;
  String driver;

  ModelWaitingDriver({this.result, this.msg, this.driver});

  ModelWaitingDriver.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    msg = json['msg'];
    driver = json['driver'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    data['msg'] = this.msg;
    data['driver'] = this.driver;
    return data;
  }
}

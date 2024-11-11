class AttendanceDataModel {
  String? jsonrpc;
  Null? id;
  Result? result;

  AttendanceDataModel({this.jsonrpc, this.id, this.result});

  AttendanceDataModel.fromJson(Map<String, dynamic> json) {
    jsonrpc = json['jsonrpc'];
    id = json['id'];
    result =
    json['result'] != null ? new Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jsonrpc'] = this.jsonrpc;
    data['id'] = this.id;
    if (this.result != null) {
      data['result'] = this.result!.toJson();
    }
    return data;
  }
}

class Result {
  String? status;
  List<Data>? data;

  Result({this.status, this.data});

  Result.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? checkIn;
  String? checkOut;
  String? location;
  String? location_out;
  String? deviceInfo;
  String? companyId;

  Data({this.id, this.checkIn, this.checkOut, this.location, this.deviceInfo, this.companyId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    checkIn = json['check_in'];
    checkOut = json['check_out'];
    location = json['location'];
    location_out= json['location_out'];
    deviceInfo = json['device_info'];
    companyId = json['company_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['check_in'] = this.checkIn;
    data['check_out'] = this.checkOut;
    data['location'] = this.location;
    data['location_out'] = this.location_out;
    data['device_info'] = this.deviceInfo;
    data['company_id'] = this.companyId;
    return data;
  }

  // Extract the date part from checkIn
  String get formattedDate {
    if (checkIn != null && checkIn!.contains(' ')) {
      return checkIn!.split(' ')[0];
    }
    return '';
  }

  // Extract the time part from checkIn
  String get formattedCheckIn {
    if (checkIn != null && checkIn!.contains(' ')) {
      return checkIn!.split(' ')[1];
    }
    return '';
  }

  // Extract the time part from checkOut
  String get formattedCheckOut {
    if (checkOut != null && checkOut!.contains(' ')) {
      return checkOut!.split(' ')[1];
    }
    return '';
  }

}

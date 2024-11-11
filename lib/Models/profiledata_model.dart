class ProfileDataModel {
  String? jsonrpc;
  Null? id;
  Result? result;

  ProfileDataModel({this.jsonrpc, this.id, this.result});

  ProfileDataModel.fromJson(Map<String, dynamic> json) {
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
  String? message;
  List<Data>? data;

  Result({this.status, this.message, this.data});

  Result.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
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
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? jobTitle;
  String? mobilePhone;
  String? workPhone;
  String? workEmail;
  String? departmentId;
  String? parentId;
  String? coachId;

  Data(
      {this.id,
        this.name,
        this.jobTitle,
        this.mobilePhone,
        this.workPhone,
        this.workEmail,
        this.departmentId,
        this.parentId,
        this.coachId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    jobTitle = json['job_title'];
    mobilePhone = json['mobile_phone'];
    workPhone = json['work_phone'];
    workEmail = json['work_email'];
    departmentId = json['department_id'];
    parentId = json['parent_id'];
    coachId = json['coach_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['job_title'] = this.jobTitle;
    data['mobile_phone'] = this.mobilePhone;
    data['work_phone'] = this.workPhone;
    data['work_email'] = this.workEmail;
    data['department_id'] = this.departmentId;
    data['parent_id'] = this.parentId;
    data['coach_id'] = this.coachId;
    return data;
  }
}

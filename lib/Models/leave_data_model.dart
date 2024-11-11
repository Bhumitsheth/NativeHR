class LeaveDataModel {
  String? jsonrpc;
  Null? id;
  Result? result;

  LeaveDataModel({this.jsonrpc, this.id, this.result});

  LeaveDataModel.fromJson(Map<String, dynamic> json) {
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
  bool? success;
  int? leaveIds;
  List<LeaveData>? leaveData;

  Result({this.success, this.leaveIds, this.leaveData});

  Result.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    leaveIds = json['leave_ids'];
    if (json['leave_data'] != null) {
      leaveData = <LeaveData>[];
      json['leave_data'].forEach((v) {
        leaveData!.add(new LeaveData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['leave_ids'] = this.leaveIds;
    if (this.leaveData != null) {
      data['leave_data'] = this.leaveData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LeaveData {
  int? leaveid;
  String? name;
  String? privatename;
  String? employeeId;
  String? holidayStatusId;
  String? dateFrom;
  String? dateTo;
  String? durationDisplay;
  String? state;
  bool? isApprove;
  bool? isValidate;
  bool? isRefuse;

  LeaveData(
      {
        this.leaveid,
        this.name,
        this.privatename,
        this.employeeId,
        this.holidayStatusId,
        this.dateFrom,
        this.dateTo,
        this.durationDisplay,
        this.state,
        this.isApprove,
        this.isValidate,
        this.isRefuse});

  LeaveData.fromJson(Map<String, dynamic> json) {
    leaveid = json['leave_id'];
    // Check if the 'name' field is a String or bool and handle accordingly
    if (json['name'] is String) {
      name = json['name'];
    } else if (json['name'] == false) {
      name = ''; // Default value when 'name' is false
    } else {
      name = null; // Handle other unexpected cases if necessary
    }
    privatename = json['private_name'];
    employeeId = json['employee_id'];
    holidayStatusId = json['holiday_status_id'];
    dateFrom = json['date_from'];
    dateTo = json['date_to'];
    // durationDisplay = json['duration_display'];
    // Check if the 'name' field is a String or bool and handle accordingly
    if (json['duration_display'] is String) {
      durationDisplay = json['duration_display'];
    } else if (json['duration_display'] == false) {
      durationDisplay = ''; // Default value when 'name' is false
    } else {
      durationDisplay = null; // Handle other unexpected cases if necessary
    }
    state = json['state'];
    isApprove = json['is_approve'];
    isValidate = json['is_validate'];
    isRefuse = json['is_refuse'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['leave_id'] = this.leaveid;
    data['name'] = this.name;
    data['private_name'] = this.privatename;
    data['employee_id'] = this.employeeId;
    data['holiday_status_id'] = this.holidayStatusId;
    data['date_from'] = this.dateFrom;
    data['date_to'] = this.dateTo;
    data['duration_display'] = this.durationDisplay;
    data['state'] = this.state;
    data['is_approve'] = this.isApprove;
    data['is_validate'] = this.isValidate;
    data['is_refuse'] = this.isRefuse;
    return data;
  }
}

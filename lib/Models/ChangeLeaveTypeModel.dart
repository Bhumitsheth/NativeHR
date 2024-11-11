class ChangeLeaveTypeModel {
  final bool success;
  final int holidayStatusId;
  final bool requestUnitDay;
  final bool requestUnitHalf;
  final bool requestUnitHours;
  final bool isAttachment;
  final String message;

  ChangeLeaveTypeModel({
    required this.success,
    required this.holidayStatusId,
    required this.requestUnitDay,
    required this.requestUnitHalf,
    required this.requestUnitHours,
    required this.isAttachment,
    required this.message,
  });

  // Factory constructor to create an instance from JSON
  factory ChangeLeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return ChangeLeaveTypeModel(
      success: json['success'],
      holidayStatusId: json['holiday_status_id'],
      requestUnitDay: json['request_unit_day'],
      requestUnitHalf: json['request_unit_half'],
      requestUnitHours: json['request_unit_hours'],
      isAttachment: json['is_attachment'],
      message: json['message'],
    );
  }
}

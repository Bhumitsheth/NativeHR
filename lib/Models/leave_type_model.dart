class LeaveType {
  final int id;
  final String displayName;

  LeaveType({required this.id, required this.displayName});

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'],
      displayName: json['display_name'],
    );
  }
}

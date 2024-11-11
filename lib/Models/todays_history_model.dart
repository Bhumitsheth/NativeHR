
// Model Class for Attendance
class TodaysHistoryModel {
  final String checkIn;
  final String checkOut;
  // final String location;

  TodaysHistoryModel({required this.checkIn, required this.checkOut, });

  factory TodaysHistoryModel.fromJson(Map<String, dynamic> json) {
    return TodaysHistoryModel(
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      // location: 'Office Location', // Replace with actual location data if available
    );
  }

  String get formattedDate => checkIn.split(' ')[0]; // Extract date part
  String get formattedCheckIn => checkIn.split(' ')[1]; // Extract time part for check-in
  String get formattedCheckOut => checkOut.split(' ')[1]; // Extract time part for check-out
}
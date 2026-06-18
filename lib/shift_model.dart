const String baseUrl = 'https://ogcleaningapp.onrender.com';

class Shift {
  final String? id;
  final int employeeId;
  final String locationId;
  final DateTime scheduleStart;
  final DateTime scheduleEnd;
  final bool clockIn;
  final bool clockOut;
  final bool managerApproval;

  Shift({
    this.id,
    required this.employeeId,
    required this.locationId,
    required this.scheduleStart,
    required this.scheduleEnd,
    this.clockIn = false,
    this.clockOut = true,
    this.managerApproval = false,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['_id'],
      employeeId: json['employeeid'],
      locationId: json['locationid'],
      scheduleStart: DateTime.parse(json['scheduleStart']).toLocal(),
      scheduleEnd: DateTime.parse(json['scheduleEnd']).toLocal(),
      clockIn: json['clockIn'] ?? false,
      clockOut: json['clockOut'] ?? true,
      managerApproval: json['managerApproval'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'employeeid': employeeId,
        'locationid': locationId,
        'scheduleStart': scheduleStart.toIso8601String(),
        'scheduleEnd': scheduleEnd.toIso8601String(),
        'clockIn': clockIn,
        'clockOut': clockOut,
        'managerApproval': managerApproval,
      };
}

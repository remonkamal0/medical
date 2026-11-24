import '../domain/reports.dart';

class DemoReportRepository implements ReportRepository {
  final _entries = <String, List<ReportEntry>>{
    'Attendance': [
      const ReportEntry({
        'Employee': 'rep',
        'Date': 'Sunday',
        'Attendance status': 'Present',
      }),
      const ReportEntry({
        'Employee': 'rep',
        'Date': 'Monday',
        'Attendance status': 'Present',
      }),
      const ReportEntry({
        'Employee': 'rep',
        'Date': 'Tuesday',
        'Attendance status': 'Absent',
      }),
      const ReportEntry({
        'Employee': 'rep',
        'Date': 'Wednesday',
        'Attendance status': 'On leave',
      }),
    ],
    'Leave requests': [
      const ReportEntry({
        'Employee': 'rep',
        'From date': 'Wednesday',
        'To date': 'Wednesday',
        'Leave type': 'Annual',
      }),
    ],
    'Weekly plan': [
      const ReportEntry({
        'Activity': 'Clinic visits',
        'Date': 'Sunday',
        'Time': '11:30 AM',
        'Notes': 'Derma Studio and Aesthetic Care Clinic',
      }),
      const ReportEntry({
        'Activity': 'Product training',
        'Date': 'Tuesday',
        'Time': '10:00 AM',
        'Notes': 'VIVACY portfolio review',
      }),
    ],
    'Doctors': [
      const ReportEntry({
        'Doctor name': 'Dr. Sara Adel',
        'Specialty': 'Dermatology',
        'Class': 'A',
        'Status': 'Active',
        'Email': 'sara@example.com',
      }),
      const ReportEntry({
        'Doctor name': 'Dr. Omar Hassan',
        'Specialty': 'Plastic surgery',
        'Class': 'B',
        'Status': 'Potential',
      }),
    ],
    'Clinics': [
      const ReportEntry({
        'Clinic name': 'Derma Studio',
        'Clinic type': 'Solo',
        'Owner': 'Dr. Sara Adel',
        'Address': 'New Cairo',
      }),
      const ReportEntry({
        'Clinic name': 'Aesthetic Care Clinic',
        'Clinic type': 'Chain',
        'Address': 'Nasr City',
      }),
    ],
    'Orders': [
      const ReportEntry({
        'Product': 'STYLAGE M',
        'Quantity': '4',
        'Bonus': '1',
        'Unit price': '5350',
        'Discount %': '10',
        'Payment method': 'InstaPay',
        'Total value': '19260.00',
      }),
    ],
    'Office': [
      const ReportEntry({
        'Activity': 'Weekly meeting',
        'Meeting with': 'Area Manager',
        'Notes': 'Review clinic follow-ups and next week’s schedule',
      }),
    ],
    'Social activities': [
      const ReportEntry({
        'Activity': 'Business cafe',
        'Location': 'New Cairo',
        'Notes': 'Introductory meeting with the clinic team',
      }),
    ],
    'Workshops and seminars': [
      const ReportEntry({
        'Event': 'VIVACY portfolio workshop',
        'Region': 'Cairo',
        'Clinic': 'Derma Studio',
        'Attendees': '12',
        'Evaluation': 'Good audience engagement',
      }),
    ],
    'Travel': [
      const ReportEntry({
        'Event': 'Local congress',
        'Destination': 'Alexandria',
        'Notes': 'Confirm attendance with the area manager',
      }),
    ],
  };

  @override
  void replace(String section, ReportEntry previous, ReportEntry next) {
    final records = _entries[section];
    final index = records?.indexOf(previous) ?? -1;
    if (index < 0) throw StateError('Report no longer exists');
    records![index] = next;
  }

  @override
  List<ReportEntry> list(String section) =>
      List.unmodifiable(_entries[section] ?? const <ReportEntry>[]);

  @override
  void add(String section, ReportEntry entry) =>
      (_entries[section] ??= []).add(entry);
}

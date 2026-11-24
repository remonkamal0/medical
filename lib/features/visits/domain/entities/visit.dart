class Visit {
  const Visit(
    this.doctor,
    this.clinic,
    this.time, {
    this.notes = '',
    this.details = const {},
    this.employee,
    this.date,
    this.escalated = false,
    this.completed = false,
  });

  final String? employee;
  final DateTime? date;
  final String doctor;
  final String clinic;
  final String time;
  final String notes;
  final Map<String, String> details;
  final bool escalated;
  final bool completed;
}

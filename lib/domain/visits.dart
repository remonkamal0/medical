enum Role { rep, manager }

class Visit {
  const Visit(
    this.doctor,
    this.clinic,
    this.time, {
    this.notes = '',
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
  final bool escalated;
  final bool completed;
}

abstract interface class VisitRepository {
  List<Visit> read();
  void add(Visit visit);
}

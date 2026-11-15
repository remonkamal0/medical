import '../domain/visits.dart';

class DemoVisitRepository implements VisitRepository {
  final _visits = [
    const Visit(
      'Dr. Laila Nasser',
      'Cairo Skin Centre',
      '10:00 AM',
      completed: true,
      notes: 'Requested updated pricing for the STYLAGE range.',
      escalated: true,
    ),
    const Visit(
      'Dr. Mina Samir',
      'Lotus Clinic',
      '9:00 AM',
      completed: true,
      notes: 'Introduced BLOOM and agreed to follow up next week.',
    ),
    const Visit('Dr. Sara Adel', 'Derma Studio', '11:30 AM'),
    const Visit('Dr. Omar Hassan', 'Aesthetic Care Clinic', '2:00 PM'),
  ];

  @override
  List<Visit> read() => List.unmodifiable(_visits);

  @override
  void add(Visit visit) => _visits.add(visit);
}

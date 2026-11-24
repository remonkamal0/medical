import '../entities/visit.dart';
import '../repositories/visit_repository.dart';

class GetVisits {
  const GetVisits(this.repository);
  final VisitRepository repository;

  List<Visit> call() => repository.read();
}

class AddVisit {
  const AddVisit(this.repository);
  final VisitRepository repository;

  void call(Visit visit) => repository.add(visit);
}

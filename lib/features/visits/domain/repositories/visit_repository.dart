import '../entities/visit.dart';

abstract interface class VisitRepository {
  List<Visit> read();
  void add(Visit visit);
}

import '../entities/report_entry.dart';
import '../repositories/report_repository.dart';

class GetReports {
  const GetReports(this.repository);
  final ReportRepository repository;

  List<ReportEntry> call(String section) => repository.list(section);
}

class AddReport {
  const AddReport(this.repository);
  final ReportRepository repository;

  void call(String section, ReportEntry entry) => repository.add(section, entry);
}

class UpdateReport {
  const UpdateReport(this.repository);
  final ReportRepository repository;

  void call(String section, ReportEntry previous, ReportEntry next) =>
      repository.replace(section, previous, next);
}

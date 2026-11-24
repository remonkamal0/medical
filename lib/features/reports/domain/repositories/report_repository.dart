import '../entities/report_entry.dart';

abstract interface class ReportRepository {
  List<ReportEntry> list(String section);
  void replace(String section, ReportEntry previous, ReportEntry next);
  void add(String section, ReportEntry entry);
}

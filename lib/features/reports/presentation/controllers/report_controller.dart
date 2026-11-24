import 'package:flutter/foundation.dart';

import '../../domain/entities/report_entry.dart';
import '../../domain/usecases/report_use_cases.dart';

class ReportController extends ChangeNotifier {
  ReportController({
    required GetReports getReports,
    required AddReport addReport,
    required UpdateReport updateReport,
  }) : _getReports = getReports,
       _addReport = addReport,
       _updateReport = updateReport;

  final GetReports _getReports;
  final AddReport _addReport;
  final UpdateReport _updateReport;

  List<ReportEntry> list(String section) => _getReports(section);

  void add(String section, ReportEntry entry) {
    _addReport(section, entry);
    notifyListeners();
  }

  void replace(String section, ReportEntry previous, ReportEntry next) {
    _updateReport(section, previous, next);
    notifyListeners();
  }
}

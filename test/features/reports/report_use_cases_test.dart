import 'package:flutter_test/flutter_test.dart';
import 'package:medical/features/reports/domain/entities/report_entry.dart';
import 'package:medical/features/reports/domain/repositories/report_repository.dart';
import 'package:medical/features/reports/domain/usecases/report_use_cases.dart';

void main() {
  test('report use cases isolate presentation from repository details', () {
    final repository = _FakeReportRepository();
    final add = AddReport(repository);
    final get = GetReports(repository);
    final update = UpdateReport(repository);
    const first = ReportEntry({'Activity': 'Visit'});
    const changed = ReportEntry({'Activity': 'Workshop'});

    add('Reports', first);
    expect(get('Reports'), [first]);

    update('Reports', first, changed);
    expect(get('Reports'), [changed]);
  });
}

class _FakeReportRepository implements ReportRepository {
  final records = <String, List<ReportEntry>>{};

  @override
  void add(String section, ReportEntry entry) =>
      (records[section] ??= []).add(entry);

  @override
  List<ReportEntry> list(String section) =>
      List.unmodifiable(records[section] ?? const []);

  @override
  void replace(String section, ReportEntry previous, ReportEntry next) {
    final index = records[section]!.indexOf(previous);
    records[section]![index] = next;
  }
}

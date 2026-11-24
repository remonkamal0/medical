import 'package:flutter/material.dart';
import '../domain/reports.dart';
import '../domain/visits.dart';
import '../domain/orders.dart';
import 'report_modules.dart';
import 'reports_dashboard.dart';
import '../features/reports/domain/usecases/report_use_cases.dart';
import '../features/visits/domain/usecases/visit_use_cases.dart';

class CeoDashboard extends StatelessWidget {
  const CeoDashboard({
    super.key,
    required this.reports,
    required this.visits,
    required this.onAttendance,
    required this.attendanceLabel,
  });
  final ReportRepository reports;
  final VisitRepository visits;
  final VoidCallback? onAttendance;
  final String attendanceLabel;

  @override
  Widget build(BuildContext context) {
    final getReports = GetReports(reports);
    final completed = GetVisits(
      visits,
    )().where((visit) => visit.completed).length;
    final orders = getReports('Orders');
    final value = orders.fold<double>(
      0,
      (sum, entry) => sum + orderTotal(orderLines(entry.values)),
    );
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('CEO overview', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('All recorded activity'),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onAttendance,
          icon: const Icon(Icons.schedule),
          label: Text(attendanceLabel),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order value',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  value.toStringAsFixed(2),
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(color: colors.primary),
                ),
                Text('${orders.length} orders · $completed completed visits'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('All reports')),
                body: ReportsDashboard(repository: reports, visits: visits),
              ),
            ),
          ),
          icon: const Icon(Icons.filter_alt_outlined),
          label: const Text('Filter and export reports'),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onAttendance,
          icon: const Icon(Icons.schedule),
          label: Text(attendanceLabel),
        ),
        for (final section in sections.keys)
          Card(
            child: ListTile(
              title: Text(section),
              trailing: Text('${getReports(section).length}'),
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => SectionPage(
                    section: section,
                    repository: reports,
                    canEdit: false,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

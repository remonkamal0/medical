import 'package:flutter/material.dart';
import '../domain/reports.dart';
import '../domain/visits.dart';
import 'report_modules.dart';
import 'report_share.dart';
import 'table_report.dart';
import 'visit_report_details.dart';
import '../features/reports/domain/usecases/report_use_cases.dart';
import '../features/visits/domain/usecases/visit_use_cases.dart';

class ReportsDashboard extends StatefulWidget {
  const ReportsDashboard({
    super.key,
    required this.repository,
    required this.visits,
  });
  final ReportRepository repository;
  final VisitRepository visits;

  @override
  State<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends State<ReportsDashboard> {
  String? employee;
  String? type;
  DateTimeRange? range;

  Visit visitFromRecord(Map<String, String> record) => Visit(
    record['Doctor'] ?? record['Doctor Name'] ?? 'Doctor',
    record['Clinic'] ?? record['Clinic Name'] ?? 'Clinic',
    record['Time'] ?? '',
    notes: record['Summary'] ?? record['Discussion Notes'] ?? '',
    details: Map.of(record)
      ..removeWhere(
        (key, _) => {
          'Report type',
          'Employee',
          'Report date',
          'Doctor',
          'Clinic',
          'Summary',
          'Time',
        }.contains(key),
      ),
    employee: record['Employee'],
    date: DateTime.tryParse(record['Report date'] ?? ''),
    completed: true,
  );

  @override
  Widget build(BuildContext context) {
    final getReports = GetReports(widget.repository);
    final getVisits = GetVisits(widget.visits);
    final records = <Map<String, String>>[
      for (final section in sections.keys)
        for (final entry in getReports(section))
          {'Report type': section, ...entry.values},
      for (final visit in getVisits().where(
        (visit) => visit.completed,
      ))
        {
          'Report type': 'Visit reports',
          'Employee': visit.employee ?? 'Unassigned',
          'Report date': visit.date?.toIso8601String().split('T').first ?? '',
          'Doctor': visit.doctor,
          'Clinic': visit.clinic,
          'Summary': visit.notes,
          ...visit.details,
        },
    ];
    final names =
        records
            .map((record) => record['Employee'] ?? 'Unassigned')
            .toSet()
            .toList()
          ..sort();
    final filtered = records.where((record) {
      final date = DateTime.tryParse(record['Report date'] ?? '');
      return (employee == null ||
              (record['Employee'] ?? 'Unassigned') == employee) &&
          (type == null || record['Report type'] == type) &&
          (range == null ||
              date != null &&
                  !date.isBefore(range!.start) &&
                  date.isBefore(range!.end.add(const Duration(days: 1))));
    }).toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Reports', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: employee,
          decoration: const InputDecoration(labelText: 'Employee'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All employees')),
            for (final name in names)
              DropdownMenuItem(value: name, child: Text(name)),
          ],
          onChanged: (value) => setState(() => employee = value),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: type,
          decoration: const InputDecoration(labelText: 'Report type'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All types')),
            for (final section in [...sections.keys, 'Visit reports'])
              DropdownMenuItem(value: section, child: Text(section)),
          ],
          onChanged: (value) => setState(() => type = value),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.date_range),
          label: Text(
            range == null
                ? 'All dates · Select period'
                : '${range!.start.toIso8601String().split('T').first} — ${range!.end.toIso8601String().split('T').first}',
          ),
          onPressed: () async {
            final selected = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDateRange: range,
            );
            if (mounted && selected != null) setState(() => range = selected);
          },
        ),
        if (range != null)
          TextButton(
            onPressed: () => setState(() => range = null),
            child: const Text('Clear date filter'),
          ),
        Row(
          children: [
            Expanded(child: Text('${filtered.length} records')),
            ReportShareButton(title: type ?? 'Reports', records: filtered),
            IconButton(
              tooltip: 'Table report',
              icon: const Icon(Icons.table_chart_outlined),
              onPressed: filtered.isEmpty
                  ? null
                  : () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TableReportPage(
                          title: type ?? 'Reports',
                          records: filtered,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        for (final record in filtered)
          Card(
            child: ListTile(
              title: Text(
                record['Report type'] == 'Visit reports'
                    ? 'Visit · ${record['Doctor'] ?? 'Doctor'}'
                    : record['Report type']!,
              ),
              subtitle: Text(
                [
                  record['Employee'] ?? 'Unassigned',
                  record['Report date'] ?? 'Undated',
                  record.entries
                          .where(
                            (field) => ![
                              'Report type',
                              'Employee',
                              'Report date',
                            ].contains(field.key),
                          )
                          .map((field) => field.value)
                          .firstOrNull ??
                      '',
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.8,
                  maxChildSize: 0.95,
                  builder: (context, controller) =>
                      record['Report type'] == 'Visit reports'
                      ? VisitReportDetails(
                          visit: visitFromRecord(record),
                          controller: controller,
                        )
                      : ListView(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                          children: [
                            Text(
                              record['Report type']!,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const Divider(height: 28),
                            for (final field in record.entries)
                              if (field.value.isNotEmpty)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(field.key),
                                  subtitle: Text(field.value),
                                ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        if (filtered.isEmpty) const Text('No reports match these filters.'),
      ],
    );
  }
}

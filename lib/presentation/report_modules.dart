import 'order_table.dart';
import 'educational_activity_form.dart';
import 'office_report_form.dart';
import 'social_activity_form.dart';
import 'table_report.dart';
import 'report_share.dart';
import 'palette.dart';
import 'package:flutter/material.dart';
import '../domain/reports.dart';
import '../domain/visits.dart';
import '../features/reports/domain/usecases/report_use_cases.dart';
import '../features/reports/presentation/controllers/report_controller.dart';

const sections = <String, List<String>>{
  'Attendance': ['Employee', 'Date', 'Attendance status', 'Notes'],
  'Leave requests': ['Employee', 'From date', 'To date', 'Leave type', 'Notes'],
  'Weekly plan': ['Activity', 'Date', 'Time', 'Notes'],
  'Doctors': [
    'Doctor name',
    'Specialty',
    'Class',
    'Status',
    'Phone',
    'Email',
    'Address',
  ],
  'Clinics': [
    'Clinic name',
    'Clinic type',
    'Owner',
    'Accountant',
    'Assistant',
    'Phone',
    'Email',
    'Address',
  ],
  'Orders': [
    'Product',
    'Quantity',
    'Bonus',
    'Unit price',
    'Discount %',
    'Payment method',
    'Delivery notes',
  ],
  'Office': ['Activity', 'Meeting with', 'Waiting time activities', 'Notes'],
  'Social activities': ['Activity', 'Location', 'Notes'],
  'Workshops and seminars': [
    'Event',
    'Company',
    'Region',
    'Area',
    'Date',
    'Clinic',
    'Trainer',
    'Objective',
    'Attendees',
    'Products and syringes used',
    'Attendee details',
    'Evaluation',
  ],
  'Travel': ['Event', 'Date', 'Destination', 'Check-out place', 'Notes'],
};

const choices = <String, List<String>>{
  'Attendance status': ['Present', 'Absent', 'On leave'],
  'Leave type': ['Annual', 'Sick', 'Personal'],
  'Specialty': ['Dermatology', 'Plastic surgery', 'Dentistry'],
  'Class': ['A', 'B', 'C'],
  'Status': ['Active', 'Potential', 'New', 'Lost'],
  'Clinic type': ['Solo', 'Chain'],
  'Payment method': [
    'Cash',
    'InstaPay',
    'Cheque · 1 month',
    'Cheque · 2 months',
    'Cheque · 3 months',
    'Credit · 1 month',
    'Credit · 2 months',
    'Credit · 3 months',
  ],
};

class ReportModules extends StatelessWidget {
  const ReportModules({
    super.key,
    required this.repository,
    required this.role,
    this.username,
  });

  final ReportRepository repository;
  final Role role;
  final String? username;

  static const groups = {
    'Field work': {
      'Weekly plan': Icons.calendar_month_outlined,
      'Doctors': Icons.medical_services_outlined,
      'Clinics': Icons.local_hospital_outlined,
      'Orders': Icons.receipt_long_outlined,
    },
    'Team time': {
      'Attendance': Icons.fact_check_outlined,
      'Leave requests': Icons.event_available_outlined,
    },
    'Activities': {
      'Office': Icons.business_outlined,
      'Social activities': Icons.coffee_outlined,
      'Workshops and seminars': Icons.school_outlined,
      'Travel': Icons.flight_outlined,
    },
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Workspace')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
          children: [
            for (final group in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Text(
                  group.key,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 300 ? 2 : 1;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final item in group.value.entries)
                        SizedBox(
                          width:
                              (constraints.maxWidth - (columns - 1) * 12) /
                              columns,
                          child: Material(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: const BorderSide(color: Color(0xffe5e1d9)),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SectionPage(
                                    section: item.key,
                                    username: username,
                                    repository: repository,
                                    canEdit: item.key == 'Attendance'
                                        ? role.isManager
                                        : role == Role.rep,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(item.value, color: medicalTeal),
                                    const SizedBox(height: 12),
                                    Text(
                                      item.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    ),
  );
}

class SectionPage extends StatefulWidget {
  const SectionPage({
    super.key,
    required this.section,
    required this.repository,
    required this.canEdit,
    this.username,
  });

  final String section;
  final ReportRepository repository;
  final bool canEdit;
  final String? username;

  @override
  State<SectionPage> createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage> {
  String query = '';
  late final ReportController controller;

  @override
  void initState() {
    super.initState();
    controller = ReportController(
      getReports: GetReports(widget.repository),
      addReport: AddReport(widget.repository),
      updateReport: UpdateReport(widget.repository),
    )..addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  Future<void> addEntry() async {
    final entry = await Navigator.push<ReportEntry>(
      context,
      MaterialPageRoute(
        builder: (_) => widget.section == 'Office'
            ? const OfficeReportForm()
            : widget.section == 'Social activities'
            ? const SocialActivityForm()
            : widget.section == 'Orders'
            ? OrderForm(
                lineBuilder: (_) =>
                    const EntryForm(section: 'Orders', orderLine: true),
              )
            : widget.section == 'Workshops and seminars'
            ? const EducationalActivityForm()
            : EntryForm(section: widget.section),
      ),
    );
    if (!mounted || entry == null) return;
    controller.add(
      widget.section,
      ReportEntry({
        ...entry.values,
        'Employee': widget.username ?? 'Unassigned',
        'Report date': DateTime.now().toIso8601String().split('T').first,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = controller
        .list(widget.section)
        .where(
          (entry) => entry.values.values.any(
            (value) => value.toLowerCase().contains(query),
          ),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section),
        actions: [
          if (widget.section == 'Weekly plan' || widget.section == 'Travel')
            IconButton(
              tooltip: 'Table report',
              icon: const Icon(Icons.table_chart_outlined),
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => TableReportPage(
                    title: widget.section,
                    records: entries.map((entry) => entry.values).toList(),
                  ),
                ),
              ),
            ),
          ReportShareButton(
            title: widget.section,
            records: entries.map((entry) => entry.values).toList(),
          ),
        ],
      ),
      floatingActionButton: widget.canEdit
          ? FloatingActionButton.extended(
              onPressed: addEntry,
              icon: const Icon(Icons.add),
              label: Text(
                widget.section == 'Weekly plan' ? 'Add activity' : 'Add record',
              ),
              backgroundColor: medicalTeal,
              foregroundColor: Colors.white,
              elevation: 0,
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: widget.section == 'Weekly plan'
                  ? 'Search activities'
                  : 'Search records',
            ),
            onChanged: (value) =>
                setState(() => query = value.trim().toLowerCase()),
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Center(
              child: Text(
                query.isEmpty ? 'No records yet' : 'No matching records',
              ),
            ),
          for (final entry in entries)
            if (widget.section == 'Orders')
              OrderTable(record: entry.values)
            else if (widget.section == 'Workshops and seminars')
              EducationalActivityCard(entry: entry)
            else
              ReportCard(section: widget.section, entry: entry),
        ],
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.section, required this.entry});
  final String section;

  final ReportEntry entry;

  @override
  Widget build(BuildContext context) {
    final values = entry.values;
    final theme = Theme.of(context).textTheme;
    final titleField = sections[section]!.first;
    final metadata = values.entries.where(
      (field) => field.key != titleField && field.value.isNotEmpty,
    );
    final icon = switch (section) {
      'Travel' => Icons.flight_takeoff_outlined,
      _ => ReportModules.groups.values.firstWhere(
        (group) => group.containsKey(section),
      )[section]!,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: medicalBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: ink,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: tealTint,
                    foregroundColor: ink,
                    child: Icon(icon),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      values[titleField] ?? '',
                      style: theme.titleLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ReportShareButton(
                    title: '$section - ${values[titleField] ?? 'Report'}',
                    records: [
                      {'Report type': section, ...values},
                    ],
                    iconColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
                ],
              ),
            ),
          ),
          if (metadata.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final field in metadata)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${field.key}  ',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: field.value),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class EntryForm extends StatefulWidget {
  const EntryForm({super.key, required this.section, this.orderLine = false});

  final String section;
  final bool orderLine;

  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final form = GlobalKey<FormState>();
  late final fields = sections[widget.section]!
      .where(
        (field) =>
            !widget.orderLine ||
            !['Payment method', 'Delivery notes'].contains(field),
      )
      .toList();
  late final controllers = {
    for (final field in fields) field: TextEditingController(),
  };
  static const numbers = {
    'Quantity',
    'Bonus',
    'Unit price',
    'Discount %',
    'Attendees',
  };

  double number(String field) =>
      double.tryParse(controllers[field]!.text.trim()) ?? 0;

  double get total =>
      number('Quantity') *
      number('Unit price') *
      (1 - number('Discount %') / 100);

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? validate(String field, String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return {
            fields.first,
            'Quantity',
            'Unit price',
            'Payment method',
          }.contains(field)
          ? 'Required'
          : null;
    }
    if (!numbers.contains(field)) return null;
    final parsed = double.tryParse(value);
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return 'Enter a valid number';
    }
    if (field == 'Discount %' && parsed > 100) {
      return 'Enter a value from 0 to 100';
    }
    if (field == 'Quantity' && parsed == 0) {
      return 'Enter a quantity greater than zero';
    }
    if ({'Quantity', 'Bonus', 'Attendees'}.contains(field) && parsed % 1 != 0) {
      return 'Enter a whole number';
    }
    return null;
  }

  Widget buildField(String field) {
    final options =
        choices[field] ??
        switch ((widget.section, field)) {
          ('Office', 'Activity') => [
            'Weekly meeting',
            'Monthly meeting',
            'Training',
            'Office work',
          ],
          ('Social activities', 'Activity') => [
            'Business cafe',
            'Business lunch',
            'Business dinner',
            'Entertainment',
          ],
          ('Travel', 'Event') => [
            'IMCAS',
            'Train the trainer',
            'Factory visit',
            'Local congress',
            'Cadaver class',
            'Stand alone',
          ],
          ('Orders', 'Product') => [
            'STYLAGE S',
            'STYLAGE M',
            'STYLAGE L',
            'STYLAGE XL',
            'STYLAGE XXL',
            'STYLAGE LIPS PLUS',
            'STYLAGE HYDRO',
            'HYALU TOX PDRN',
            'ACN EXO SHOT',
            'DHT EXO SHOT',
          ],
          _ => null,
        };
    if (options != null) {
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: field),
        isExpanded: true,
        items: [
          for (final value in options)
            DropdownMenuItem(value: value, child: Text(value)),
        ],
        onChanged: (value) => controllers[field]!.text = value ?? '',
        validator: (value) => validate(field, value),
      );
    }
    final calendar =
        field.endsWith('date') || field == 'Date' || field == 'Time';
    return TextFormField(
      decoration: InputDecoration(
        labelText: field,
        suffixIcon: calendar
            ? Icon(
                field.endsWith('date') || field == 'Date'
                    ? Icons.calendar_today
                    : Icons.schedule,
              )
            : null,
      ),
      controller: controllers[field],
      readOnly: calendar,
      keyboardType: numbers.contains(field)
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      onChanged: numbers.contains(field) ? (_) => setState(() {}) : null,
      validator: (value) => validate(field, value),
      onTap: calendar
          ? () async {
              if (field.endsWith('date') || field == 'Date') {
                final today = DateTime.now();
                final date = await showDatePicker(
                  context: context,
                  initialDate: today,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (mounted && date != null) {
                  controllers[field]!.text = MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(date);
                }
              } else {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (mounted && time != null) {
                  controllers[field]!.text = time.format(context);
                }
              }
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.section)),
    body: SafeArea(
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            for (final field in fields)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: buildField(field),
              ),
            if (widget.section == 'Orders')
              ListTile(
                title: const Text('Total value'),
                trailing: Text(total.toStringAsFixed(2)),
              ),
            FilledButton(
              onPressed: () {
                if (!form.currentState!.validate() ||
                    (widget.section == 'Orders' && !total.isFinite)) {
                  return;
                }
                Navigator.pop(
                  context,
                  ReportEntry(
                    Map.unmodifiable({
                      for (final field in fields)
                        field: controllers[field]!.text.trim(),
                      if (widget.section == 'Orders')
                        'Total value': total.toStringAsFixed(2),
                    }),
                  ),
                );
              },
              child: const Text('Save record'),
            ),
          ],
        ),
      ),
    ),
  );
}

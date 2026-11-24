import 'package:flutter/material.dart';
import '../domain/reports.dart';
import 'report_share.dart';

const activityFields = [
  'Event',
  'Company',
  'Region',
  'Area',
  'Date',
  'Product specialist',
  'Clinic / Center',
  'Trainer name',
  'Event objective',
];
const syringeProducts = [
  'M',
  'M LIDO',
  'L',
  'L LIDO',
  'XL',
  'XL LIDO',
  'XXL',
  'HYDRO',
  'LIPS PLUS',
  'HYALU TOX',
  'ACN EXO SHOT',
  'DHT EXO SHOT',
];
const attendeeFields = [
  'Doctor name',
  'Mobile',
  'Speciality',
  'Birthday',
  'Clinic',
  'Email',
];
const evaluationItems = [
  'Start on time',
  'The brand is well presented',
  'Trainer uses the official VIVACY / BLOOM topic presentation',
  'Professional photographer and videographer',
  'Audience engagement',
  'Audience acceptance',
  'Hands-on attendees: 4 doctors / model',
  'Materials used: 4 syringes / model',
  'Tools checklist fulfilled',
  'Proper setup',
  'Overall rating',
];

class EducationalActivityForm extends StatefulWidget {
  const EducationalActivityForm({super.key});

  @override
  State<EducationalActivityForm> createState() =>
      _EducationalActivityFormState();
}

class EducationalActivityCard extends StatelessWidget {
  const EducationalActivityCard({super.key, required this.entry});

  final ReportEntry entry;

  static const activityKeys = [
    'Company',
    'Region',
    'Area',
    'Date',
    'Product specialist',
    'Clinic / Center',
    'Trainer name',
    'Event objective',
  ];

  static const attendeeFields = [
    'Doctor name',
    'Mobile',
    'Speciality',
    'Birthday',
    'Clinic',
    'Email',
  ];

  @override
  Widget build(BuildContext context) {
    final values = entry.values;
    final colors = Theme.of(context).colorScheme;
    final syringes = values.entries
        .where((item) => item.key.startsWith('Syringes / '))
        .toList();
    final evaluations = values.entries
        .where((item) => item.key.startsWith('Evaluation / '))
        .toList();
    final attendeeCount =
        int.tryParse(values['Number of attendees'] ?? '') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primary.withValues(alpha: .72)],
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.onPrimary,
                  foregroundColor: colors.primary,
                  child: const Icon(Icons.school_outlined),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        values['Event'] ?? 'Educational activity',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${values['Date'] ?? 'No date'}  •  $attendeeCount attendees',
                        style: TextStyle(
                          color: colors.onPrimary.withValues(alpha: .85),
                        ),
                      ),
                    ],
                  ),
                ),
                ReportShareButton(
                  title: values['Event'] ?? 'Educational activity report',
                  records: [
                    {'Report type': 'Workshops and seminars', ...values},
                  ],
                  iconColor: colors.onPrimary,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ActivitySection(
                  title: 'Activity information',
                  icon: Icons.event_note_outlined,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final key in activityKeys)
                        if ((values[key] ?? '').isNotEmpty)
                          _InfoTile(label: key, value: values[key]!),
                    ],
                  ),
                ),
                if (syringes.isNotEmpty)
                  _ActivitySection(
                    title: 'Products and syringes used',
                    icon: Icons.vaccines_outlined,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final item in syringes)
                          Chip(
                            avatar: const Icon(Icons.medication_outlined, size: 18),
                            label: Text(
                              '${item.key.replaceFirst('Syringes / ', '')} · ${item.value}',
                            ),
                          ),
                      ],
                    ),
                  ),
                if (attendeeCount > 0)
                  _ActivitySection(
                    title: 'Attendees information',
                    icon: Icons.groups_outlined,
                    child: Column(
                      children: [
                        for (var index = 0; index < attendeeCount; index++)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  child: Text('${index + 1}'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Wrap(
                                    spacing: 18,
                                    runSpacing: 8,
                                    children: [
                                      for (final field in attendeeFields)
                                        if ((values['Attendee ${index + 1} / $field'] ?? '')
                                            .isNotEmpty)
                                          _InlineDetail(
                                            label: field,
                                            value: values[
                                                'Attendee ${index + 1} / $field']!,
                                          ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                if (evaluations.isNotEmpty)
                  _ActivitySection(
                    title: 'Evaluation form',
                    icon: Icons.fact_check_outlined,
                    child: Column(
                      children: [
                        for (final item in evaluations)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: colors.outlineVariant),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.key.replaceFirst('Evaluation / ', ''),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    item.value,
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  children: [
                    if ((values['Employee'] ?? '').isNotEmpty)
                      Chip(
                        avatar: const Icon(Icons.person_outline, size: 18),
                        label: Text(values['Employee']!),
                      ),
                    if ((values['Report date'] ?? '').isNotEmpty)
                      Chip(
                        avatar: const Icon(Icons.calendar_today_outlined, size: 16),
                        label: Text(values['Report date']!),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 145),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _InlineDetail extends StatelessWidget {
  const _InlineDetail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 155,
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label\n',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}

class _EducationalActivityFormState extends State<EducationalActivityForm> {
  final form = GlobalKey<FormState>();
  final activity = <String, String>{};
  final quantities = <String, String>{};
  final ratings = <String, String>{};
  final attendees = List.generate(15, (_) => <String, String>{});

  int get attendeeCount => attendees
      .where((attendee) => (attendee['Doctor name'] ?? '').trim().isNotEmpty)
      .length;

  String? quantityValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final number = int.tryParse(value);
    return number == null || number < 0
        ? 'Enter a whole number of 0 or more'
        : null;
  }

  Future<void> pickDate(FormFieldState<String> field) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (!mounted || date == null) return;
    field.didChange(date.toIso8601String().split('T').first);
  }

  Widget dateField(String label, Map<String, String> target) =>
      FormField<String>(
        initialValue: target[label],
        onSaved: (value) => target[label] = value ?? '',
        builder: (field) => InkWell(
          onTap: () => pickDate(field),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
            child: Text(
              field.value?.isNotEmpty == true ? field.value! : 'Select date',
            ),
          ),
        ),
      );

  Widget heading(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
  );

  Widget activityField(String field) => field == 'Date'
      ? dateField(field, activity)
      : TextFormField(
          decoration: InputDecoration(labelText: field),
          onSaved: (value) => activity[field] = value?.trim() ?? '',
          validator: field == 'Event'
              ? (value) => value == null || value.trim().isEmpty
                    ? 'Enter the event name'
                    : null
              : null,
        );

  Widget activityInformation() {
    const rows = [
      ('Event', 'Company'),
      ('Region', 'Area'),
      ('Date', 'Product specialist'),
      ('Clinic / Center', 'Trainer name'),
      ('Event objective', 'Number of attendees'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 560;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              for (final row in rows) ...[
                if (twoColumns)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: activityField(row.$1)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: row.$2 == 'Number of attendees'
                            ? InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Number of attendees',
                                  prefixIcon: Icon(Icons.groups_outlined),
                                ),
                                child: Text('$attendeeCount'),
                              )
                            : activityField(row.$2),
                      ),
                    ],
                  )
                else ...[
                  activityField(row.$1),
                  const SizedBox(height: 12),
                  if (row.$2 == 'Number of attendees')
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Number of attendees',
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                      child: Text('$attendeeCount'),
                    )
                  else
                    activityField(row.$2),
                ],
                if (row != rows.last) const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget attendeesTable() => Container(
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(18),
    ),
    clipBehavior: Clip.antiAlias,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.primaryContainer,
        ),
        columnSpacing: 12,
        horizontalMargin: 10,
        columns: [
          const DataColumn(label: Text('#')),
          for (final field in attendeeFields) DataColumn(label: Text(field)),
        ],
        rows: [
          for (var index = 0; index < attendees.length; index++)
            DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                for (final field in attendeeFields)
                  DataCell(
                    SizedBox(
                      width: field == 'Doctor name' ? 150 : 125,
                      child: TextFormField(
                        initialValue: attendees[index][field],
                        decoration: InputDecoration(
                          hintText: field == 'Birthday'
                              ? 'YYYY-MM-DD'
                              : field,
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        keyboardType: field == 'Mobile'
                            ? TextInputType.phone
                            : field == 'Email'
                            ? TextInputType.emailAddress
                            : TextInputType.text,
                        onChanged: (value) => setState(
                          () => attendees[index][field] = value.trim(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    ),
  );

  Widget evaluationTable() => Container(
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(18),
    ),
    clipBehavior: Clip.antiAlias,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.primaryContainer,
        ),
        columns: const [
          DataColumn(label: Text('ITEM')),
          DataColumn(label: Text('RATING')),
        ],
        rows: [
          for (final item in evaluationItems)
            DataRow(
              cells: [
                DataCell(SizedBox(width: 560, child: Text(item))),
                DataCell(
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: ratings[item],
                      decoration: const InputDecoration(
                        hintText: 'Choose rating',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      items: [
                        for (final rating in [
                          '1 - Poor',
                          '2 - Fair',
                          '3 - Good',
                          '4 - Very good',
                          '5 - Excellent',
                          'Not applicable',
                        ])
                          DropdownMenuItem(value: rating, child: Text(rating)),
                      ],
                      onChanged: (value) {
                        if (value != null) ratings[item] = value;
                      },
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );

  void save() {
    if (!form.currentState!.validate()) return;
    form.currentState!.save();
    final completedAttendees = attendees
        .where((attendee) => (attendee['Doctor name'] ?? '').trim().isNotEmpty)
        .toList();
    Navigator.pop(
      context,
      ReportEntry(
        Map.unmodifiable({
          ...activity,
          'Number of attendees': completedAttendees.length.toString(),
          for (final product in syringeProducts)
            if ((int.tryParse(quantities[product] ?? '') ?? 0) > 0)
              'Syringes / $product': quantities[product]!,
          for (var index = 0; index < completedAttendees.length; index++)
            for (final field in attendeeFields)
              if ((completedAttendees[index][field] ?? '').isNotEmpty)
                'Attendee ${index + 1} / $field': completedAttendees[index][field]!,
          for (final item in evaluationItems)
            if (ratings.containsKey(item)) 'Evaluation / $item': ratings[item]!,
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Educational activity report')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Form(
            key: form,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                heading('Activity information'),
                activityInformation(),
                heading('Products and syringes used'),
                const Text('Enter the quantity used for each product.'),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900
                        ? 4
                        : constraints.maxWidth >= 560
                        ? 2
                        : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 12) / columns;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final product in syringeProducts)
                          SizedBox(
                            width: width,
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: product,
                                hintText: '0',
                                prefixIcon: const Icon(
                                  Icons.vaccines_outlined,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: quantityValidator,
                              onSaved: (value) => quantities[product] =
                                  value?.trim() ?? '',
                            ),
                          ),
                      ],
                    );
                  },
                ),
                heading('Attendees information ($attendeeCount/15)'),
                const Text(
                  'Enter attendee data directly in the table. Empty rows will not be saved.',
                ),
                const SizedBox(height: 12),
                attendeesTable(),
                heading('Evaluation'),
                const Text(
                  'Rate each item from 1 (Poor) to 5 (Excellent), or choose Not applicable.',
                ),
                const SizedBox(height: 12),
                evaluationTable(),
                const SizedBox(height: 24),
                FilledButton(onPressed: save, child: const Text('Save report')),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

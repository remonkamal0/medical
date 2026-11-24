import 'package:flutter/material.dart';

import '../domain/reports.dart';

const officeActivities = <String>[
  'Weekly Meeting',
  'Monthly Meeting',
  'Training',
  'Office Work',
];

const meetingRoles = <String>[
  'Senior Product Specialist',
  'Product Supervisor',
  'Product Manager',
  'Area Manager',
  'Marketing Director',
  'Scientific Director',
  'CEO',
];

class OfficeReportForm extends StatefulWidget {
  const OfficeReportForm({super.key});

  @override
  State<OfficeReportForm> createState() => _OfficeReportFormState();
}

class _OfficeReportFormState extends State<OfficeReportForm> {
  final form = GlobalKey<FormState>();
  final attendees = <String>{};
  String? activity;
  String notes = '';

  void save() {
    if (!form.currentState!.validate()) return;
    form.currentState!.save();
    Navigator.pop(
      context,
      ReportEntry({
        'Activity': activity!,
        if (activity == 'Weekly Meeting') 'Meeting with': attendees.join(', '),
        if (notes.isNotEmpty) 'Notes': notes,
      }),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Office report')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: form,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Office activity',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                FormField<String>(
                  validator: (_) =>
                      activity == null ? 'Choose an office activity' : null,
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final option in officeActivities)
                            ChoiceChip(
                              label: Text(option),
                              selected: activity == option,
                              onSelected: (_) => setState(() {
                                activity = option;
                                field.didChange(option);
                                if (option != 'Weekly Meeting') {
                                  attendees.clear();
                                }
                              }),
                            ),
                        ],
                      ),
                      if (field.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 4),
                          child: Text(
                            field.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (activity == 'Weekly Meeting') ...[
                  const SizedBox(height: 20),
                  Text(
                    'Meeting with',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FormField<Set<String>>(
                    validator: (_) => attendees.isEmpty
                        ? 'Choose at least one attendee'
                        : null,
                    builder: (field) => Column(
                      children: [
                        for (final role in meetingRoles)
                          CheckboxListTile(
                            value: attendees.contains(role),
                            title: Text(role),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (selected) => setState(() {
                              selected == true
                                  ? attendees.add(role)
                                  : attendees.remove(role);
                              field.didChange(Set.of(attendees));
                            }),
                          ),
                        if (field.hasError)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              field.errorText!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 4,
                  onSaved: (value) => notes = value?.trim() ?? '',
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: save,
                  child: const Text('Save office report'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

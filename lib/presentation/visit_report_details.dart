import 'package:flutter/material.dart';

import '../domain/visits.dart';
import 'order_table.dart';
import 'report_share.dart';

class VisitReportDetails extends StatelessWidget {
  const VisitReportDetails({
    super.key,
    required this.visit,
    required this.controller,
  });

  final Visit visit;
  final ScrollController controller;

  static const groups = <String, List<String>>{
    'Visit overview': ['Visit Objectives', 'Visit Type', 'Visit With'],
    'Doctor': [
      'Specialty',
      'Class',
      'Doctor Status',
      'Doctor Phone',
      'Doctor Email',
      'Doctor Address',
      'New Doctor Source',
      'Lost Doctor Reasons',
    ],
    'Clinic': [
      'Clinic Type',
      'Chain Number',
      'Owner Name',
      'Owner Phone',
      'Accountant Name',
      'Accountant Phone',
      'Assistant Name',
      'Assistant Phone',
    ],
    'Products and feedback': [
      'Promoted Products',
      'Doctor Feedback',
      'VIVACY Competitors',
      'BLOOM Competitors',
    ],
    'Discussion and service': [
      'Service Request',
      'Discussion Summary',
      'Discussion Notes',
    ],
    'Issues and complaints': ['Issues & Complaints', 'Issue Description'],
    'Order and follow-up': [
      'Order Details',
      'Delivery Notes',
      'Payment Method',
      'Next Proposed Visit',
      'Planned vs Delayed',
    ],
  };

  IconData sectionIcon(String section) => switch (section) {
    'Visit overview' => Icons.assignment_outlined,
    'Doctor' => Icons.person_outline,
    'Clinic' => Icons.local_hospital_outlined,
    'Products and feedback' => Icons.medication_outlined,
    'Discussion and service' => Icons.forum_outlined,
    'Issues and complaints' => Icons.report_problem_outlined,
    _ => Icons.event_available_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Visit report',
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ReportShareButton(
              title: 'Visit report - ${visit.doctor}',
              records: [
                {
                  'Doctor': visit.doctor,
                  'Clinic': visit.clinic,
                  'Time': visit.time,
                  if (visit.employee != null) 'Employee': visit.employee!,
                  if (visit.date != null)
                    'Report date': visit.date!
                        .toIso8601String()
                        .split('T')
                        .first,
                  ...visit.details,
                },
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.primary.withValues(alpha: .72)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colors.onPrimary,
                    foregroundColor: colors.primary,
                    child: const Icon(Icons.medical_services_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.doctor,
                          style: text.headlineSmall?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          visit.clinic,
                          style: text.bodyLarge?.copyWith(
                            color: colors.onPrimary.withValues(alpha: .86),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(icon: Icons.schedule, label: visit.time),
                  if (visit.date != null)
                    _StatusChip(
                      icon: Icons.calendar_today_outlined,
                      label: visit.date!.toIso8601String().split('T').first,
                    ),
                  _StatusChip(
                    icon: Icons.task_alt,
                    label: visit.completed ? 'Completed' : 'Planned',
                  ),
                  if (visit.escalated)
                    const _StatusChip(
                      icon: Icons.flag_outlined,
                      label: 'Manager follow-up',
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (final group in groups.entries)
          if (group.value.any((key) => (visit.details[key] ?? '').isNotEmpty))
            _ReportSection(
              title: group.key,
              icon: sectionIcon(group.key),
              fields: [
                for (final key in group.value)
                  if ((visit.details[key] ?? '').isNotEmpty)
                    MapEntry(key, visit.details[key]!),
              ],
            ),
        if ((visit.details['Order items'] ?? '').isNotEmpty)
          OrderTable(record: visit.details),
      ],
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.title,
    required this.icon,
    required this.fields,
  });
  final String title;
  final IconData icon;
  final List<MapEntry<String, String>> fields;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: colors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < fields.length; index++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fields[index].key,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(fields[index].value),
                ],
              ),
            ),
            if (index < fields.length - 1)
              Divider(color: colors.outlineVariant, height: 1),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    ),
  );
}

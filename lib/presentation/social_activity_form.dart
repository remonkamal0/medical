import 'package:flutter/material.dart';

import '../domain/reports.dart';

class SocialActivityForm extends StatefulWidget {
  const SocialActivityForm({super.key});

  @override
  State<SocialActivityForm> createState() => _SocialActivityFormState();
}

class _SocialActivityFormState extends State<SocialActivityForm> {
  final form = GlobalKey<FormState>();
  final location = TextEditingController();
  final notes = TextEditingController();
  String? activity;

  static const activities = <(String, IconData)>[
    ('Business Cafe', Icons.local_cafe_outlined),
    ('Business Lunch', Icons.lunch_dining_outlined),
    ('Business Dinner', Icons.dinner_dining_outlined),
    ('Entertainment', Icons.celebration_outlined),
  ];

  @override
  void dispose() {
    location.dispose();
    notes.dispose();
    super.dispose();
  }

  void save() {
    if (activity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose the social activity type.')),
      );
      return;
    }
    if (!form.currentState!.validate()) return;
    Navigator.pop(
      context,
      ReportEntry({
        'Activity': activity!,
        'Location': location.text.trim(),
        'Notes': notes.text.trim(),
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Social activity report')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: form,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Activity type',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose the activity completed during the field day.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 18),
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.9,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final item in activities)
                        InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => setState(() => activity = item.$1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: activity == item.$1
                                  ? colors.primaryContainer
                                  : colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: activity == item.$1
                                    ? colors.primary
                                    : colors.outlineVariant,
                                width: activity == item.$1 ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(item.$2, color: colors.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.$1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (activity == item.$1)
                                  Icon(Icons.check_circle, color: colors.primary),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: location,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Location is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notes,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save social activity report'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

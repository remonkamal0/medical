import '../domain/reports.dart';
import 'package:flutter/material.dart';
import '../domain/visits.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.username,
    required this.details,
    required this.onEdit,
    required this.visits,
    required this.repository,
    required this.role,
    required this.mode,
    required this.onModeChanged,
    required this.onSignOut,
  });

  final String username;
  final (String, String)? details;
  final ValueChanged<(String, String)> onEdit;
  final VisitRepository visits;
  final ReportRepository repository;
  final Role role;
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onModeChanged;
  final VoidCallback onSignOut;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String get displayName => widget.details?.$1 ?? widget.username;
  String get email => widget.details?.$2 ?? '';

  Future<void> editProfile() async {
    var name = displayName;
    var address = email;
    final form = GlobalKey<FormState>();
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Edit profile'),
        content: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Display name'),
                  onChanged: (value) => name = value,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: address,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => address = value,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(dialog, (name.trim(), address.trim()));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    widget.onEdit(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final alerts = widget.role == Role.manager
        ? widget.visits.read().where((visit) => visit.escalated).toList()
        : const <Visit>[];
    final records = widget.repository
        .list('Attendance')
        .where(
          (entry) =>
              widget.role == Role.manager ||
              entry.values['Employee'] == widget.username,
        );
    final totals = {
      for (final status in ['Present', 'Absent', 'On leave'])
        status: records
            .where((entry) => entry.values['Attendance status'] == status)
            .length,
    };
    final total = totals.values.fold(0, (sum, count) => sum + count);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'My Profile',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    child: Text(
                      displayName.isEmpty
                          ? '?'
                          : displayName.characters.first.toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          widget.role == Role.manager
                              ? 'Manager'
                              : 'Medical representative',
                          style: TextStyle(color: colors.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    for (final (index, item) in totals.entries.indexed) ...[
                      if (index > 0)
                        VerticalDivider(
                          width: 1,
                          color: colors.outlineVariant,
                          indent: 14,
                          endIndent: 14,
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 4,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                [
                                  Icons.check_circle_outline,
                                  Icons.event_busy_outlined,
                                  Icons.event_available_outlined,
                                ][index],
                                color: colors.primary,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item.value}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item.key,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.role == Role.manager ? 'Team attendance' : 'My attendance',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: colors.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final item in totals.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [Text(item.key), Text('${item.value}')],
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: total == 0 ? 0 : item.value / total,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(8),
                              color: item.key == 'Absent'
                                  ? colors.error
                                  : item.key == 'On leave'
                                  ? colors.tertiary
                                  : colors.primary,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit profile'),
              subtitle: email.isEmpty ? null : Text(email),
              trailing: const Icon(Icons.chevron_right),
              onTap: editProfile,
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Notifications')),
                    body: alerts.isEmpty
                        ? const Center(child: Text('No notifications yet'))
                        : ListView(
                            children: [
                              for (final visit in alerts)
                                ListTile(
                                  leading: const Icon(Icons.flag_outlined),
                                  title: Text(
                                    'Follow-up needed: ${visit.doctor}',
                                  ),
                                  subtitle: Text(visit.clinic),
                                ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Appearance', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ],
              selected: {widget.mode},
              onSelectionChanged: (selection) =>
                  widget.onModeChanged(selection.single),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: widget.onSignOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

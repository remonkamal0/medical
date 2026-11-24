import '../domain/reports.dart';
import 'package:flutter/material.dart';
import '../domain/visits.dart';
import '../features/reports/domain/usecases/report_use_cases.dart';
import '../features/visits/domain/usecases/visit_use_cases.dart';

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
  late final GetReports _getReports;
  late final GetVisits _getVisits;

  @override
  void initState() {
    super.initState();
    _getReports = GetReports(widget.repository);
    _getVisits = GetVisits(widget.visits);
  }

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
    final alerts = widget.role.isManager
        ? _getVisits().where((visit) => visit.escalated).toList()
        : const <Visit>[];
    final records = _getReports('Attendance')
        .where(
          (entry) =>
              widget.role.isManager ||
              entry.values['Employee'] == widget.username,
        );
    final totals = {
      for (final status in ['Present', 'Absent', 'On leave'])
        status: records
            .where((entry) => entry.values['Attendance status'] == status)
            .length,
    };
    final total = totals.values.fold(0, (sum, count) => sum + count);
    final roleLabel = widget.role.isManager
        ? widget.role.label
        : 'Medical representative';
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final hero = _ProfileHero(
          name: displayName,
          email: email,
          role: roleLabel,
          onEdit: editProfile,
        );
        final attendance = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AttendanceStats(totals: totals),
            const SizedBox(height: 18),
            _AttendanceChart(
              title: widget.role.isManager
                  ? 'Team attendance overview'
                  : 'My attendance overview',
              totals: totals,
              total: total,
            ),
          ],
        );
        final settings = _ProfileSettings(
          email: email,
          alerts: alerts,
          mode: widget.mode,
          onEdit: editProfile,
          onModeChanged: widget.onModeChanged,
          onSignOut: widget.onSignOut,
        );
        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 40 : 20,
            vertical: 28,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'My profile',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your account, attendance and application preferences.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    hero,
                    const SizedBox(height: 22),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: attendance),
                          const SizedBox(width: 22),
                          Expanded(flex: 4, child: settings),
                        ],
                      )
                    else ...[
                      attendance,
                      const SizedBox(height: 18),
                      settings,
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.email,
    required this.role,
    required this.onEdit,
  });

  final String name;
  final String email;
  final String role;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, const Color(0xff124052)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: .2),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: .35)),
            ),
            child: Text(
              name.isEmpty ? '?' : name.characters.first.toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email.isEmpty ? role : '$role  •  $email',
                  style: TextStyle(color: Colors.white.withValues(alpha: .8)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Active account',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Edit profile',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class _AttendanceStats extends StatelessWidget {
  const _AttendanceStats({required this.totals});
  final Map<String, int> totals;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final items = [
      ('Present', Icons.check_circle_outline, colors.primary),
      ('Absent', Icons.event_busy_outlined, colors.error),
      ('On leave', Icons.beach_access_outlined, colors.tertiary),
    ];
    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(items[index].$2, color: items[index].$3),
                  const SizedBox(height: 14),
                  Text(
                    '${totals[items[index].$1] ?? 0}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    items[index].$1,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AttendanceChart extends StatelessWidget {
  const _AttendanceChart({
    required this.title,
    required this.totals,
    required this.total,
  });
  final String title;
  final Map<String, int> totals;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 22),
          for (final item in totals.entries) ...[
            Row(
              children: [
                Expanded(child: Text(item.key)),
                Text(
                  total == 0
                      ? '0%'
                      : '${(item.value / total * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: total == 0 ? 0 : item.value / total,
              minHeight: 10,
              borderRadius: BorderRadius.circular(12),
              color: item.key == 'Absent'
                  ? colors.error
                  : item.key == 'On leave'
                  ? colors.tertiary
                  : colors.primary,
              backgroundColor: colors.surfaceContainerHighest,
            ),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}

class _ProfileSettings extends StatelessWidget {
  const _ProfileSettings({
    required this.email,
    required this.alerts,
    required this.mode,
    required this.onEdit,
    required this.onModeChanged,
    required this.onSignOut,
  });
  final String email;
  final List<Visit> alerts;
  final ThemeMode mode;
  final VoidCallback onEdit;
  final ValueChanged<ThemeMode> onModeChanged;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Account settings',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Personal information',
            subtitle: email.isEmpty ? 'Add your email and name' : email,
            onTap: onEdit,
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: alerts.isEmpty
                ? 'No new notifications'
                : '${alerts.length} reports need attention',
            badge: alerts.length,
            onTap: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Notifications')),
                  body: alerts.isEmpty
                      ? const Center(child: Text('No notifications yet'))
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            for (final visit in alerts)
                              Card(
                                child: ListTile(
                                  leading: const Icon(Icons.flag_outlined),
                                  title: Text(
                                    'Follow-up needed: ${visit.doctor}',
                                  ),
                                  subtitle: Text(visit.clinic),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Appearance',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('Dark'),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.settings_suggest_outlined),
                label: Text('Auto'),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (selection) =>
                onModeChanged(selection.single),
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge = 0,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(child: Icon(icon)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(subtitle),
    trailing: badge > 0
        ? Badge(label: Text('$badge'))
        : const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

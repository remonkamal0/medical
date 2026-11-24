import 'ceo_dashboard.dart';
import 'reports_dashboard.dart';
import 'visit_report_form.dart';
import 'visit_report_details.dart';
import 'table_report.dart';
import 'report_share.dart';
import 'profile.dart';
import 'palette.dart';
import '../domain/auth.dart';
import 'sign_in.dart';
import '../domain/reports.dart';
import 'report_modules.dart';
import 'package:flutter/material.dart';
import '../domain/visits.dart';
import '../core/di/app_dependencies.dart';
import '../features/auth/domain/usecases/sign_in_user.dart';
import '../features/reports/domain/usecases/report_use_cases.dart';
import '../features/visits/domain/usecases/visit_use_cases.dart';

class MedicalApp extends StatefulWidget {
  const MedicalApp({
    super.key,
    required this.dependencies,
  });
  final AppDependencies dependencies;

  @override
  State<MedicalApp> createState() => _MedicalAppState();
}

class _MedicalAppState extends State<MedicalApp> {
  ThemeMode mode = ThemeMode.system;

  ThemeData theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: medicalTeal,
          brightness: brightness,
          surface: dark ? const Color(0xff101a20) : paper,
        ).copyWith(
          primary: dark ? const Color(0xff83d7cb) : medicalTeal,
          onSurface: dark ? const Color(0xffedf4f5) : ink,
          surfaceContainerLow: dark ? const Color(0xff1b2930) : Colors.white,
        );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.primaryContainer,
        backgroundColor: scheme.surfaceContainerLow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Aesthetic Daily',
    debugShowCheckedModeBanner: false,
    theme: theme(Brightness.light),
    darkTheme: theme(Brightness.dark),
    themeMode: mode,
    home: Workspace(
      repository: widget.dependencies.visitRepository,
      reports: widget.dependencies.reportRepository,
      auth: widget.dependencies.authRepository,
      mode: mode,
      onModeChanged: (value) => setState(() => mode = value),
    ),
  );
}

class Workspace extends StatefulWidget {
  const Workspace({
    super.key,
    required this.repository,
    required this.reports,
    required this.auth,
    required this.mode,
    required this.onModeChanged,
  });
  final VisitRepository repository;
  final ReportRepository reports;
  final AuthRepository auth;
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onModeChanged;

  @override
  State<Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  late final GetVisits _getVisits;
  late final AddVisit _addVisit;
  late final GetReports _getReports;
  late final AddReport _addReport;
  late final UpdateReport _updateReport;

  @override
  void initState() {
    super.initState();
    _getVisits = GetVisits(widget.repository);
    _addVisit = AddVisit(widget.repository);
    _getReports = GetReports(widget.reports);
    _addReport = AddReport(widget.reports);
    _updateReport = UpdateReport(widget.reports);
  }

  Role? role;
  String username = '';
  final profileDetails = <String, (String, String)>{};
  int tab = 0;
  TimeOfDay? started;
  TimeOfDay? ended;

  ReportEntry? get attendance {
    final today = DateTime.now().toIso8601String().split('T').first;
    return _getReports('Attendance')
        .where(
          (entry) =>
              entry.values['Employee'] == username &&
              entry.values['Report date'] == today &&
              entry.values.containsKey('Check in'),
        )
        .firstOrNull;
  }

  Future<void> recordAttendance() async {
    final existing = attendance;
    if (existing?.values.containsKey('Check out') == true) return;
    var place = '';
    final form = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(existing == null ? 'Start of the day' : 'End of the day'),
        content: Form(
          key: form,
          child: TextFormField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Place'),
            onChanged: (value) => place = value.trim(),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter your place'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(dialog, true);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final now = DateTime.now();
    final record = ReportEntry({
      ...?existing?.values,
      'Employee': username,
      'Role': role!.label,
      'Report date':
          existing?.values['Report date'] ??
          now.toIso8601String().split('T').first,
      'Attendance status': 'Present',
      if (existing == null) ...{
        'Check in': now.toIso8601String(),
        'Check-in place': place,
      } else ...{
        'Check out': now.toIso8601String(),
        'Check-out place': place,
        'Working minutes': now
            .difference(DateTime.parse(existing.values['Check in']!))
            .inMinutes
            .toString(),
      },
    });
    setState(() {
      if (existing == null) {
        _addReport('Attendance', record);
        started = TimeOfDay.fromDateTime(now);
      } else {
        _updateReport('Attendance', existing, record);
        ended = TimeOfDay.fromDateTime(now);
      }
    });
  }

  void signOut() => setState(() {
    role = null;
    username = '';
    tab = 0;
    started = null;
    ended = null;
  });

  void openModules() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ReportModules(
          repository: widget.reports,
          role: role!,
          username: username,
        ),
      ),
    );
  }

  Future<void> addVisit() async {
    final visit = await Navigator.of(
      context,
    ).push<Visit>(MaterialPageRoute(builder: (_) => const VisitReportForm()));
    if (!mounted || visit == null) return;
    setState(() {
      _addVisit(
        Visit(
          visit.doctor,
          visit.clinic,
          visit.time,
          notes: visit.notes,
          details: visit.details,
          completed: visit.completed,
          escalated: visit.escalated,
          employee: username,
          date: DateTime.now(),
        ),
      );
      tab = 2;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Visit report saved for ${visit.doctor}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = role?.isManager == true;
    final visits = _getVisits();
    final reports = visits.where((visit) => visit.completed).toList();
    final theme = Theme.of(context).textTheme;
    if (role == null) {
      return SignIn(
        signIn: SignInUser(widget.auth),
        onSignedIn: (name, value) => setState(() {
          username = name;
          role = value;
          final saved = attendance;
          started = saved == null
              ? null
              : TimeOfDay.fromDateTime(
                  DateTime.parse(saved.values['Check in']!),
                );
          ended = saved?.values['Check out'] == null
              ? null
              : TimeOfDay.fromDateTime(
                  DateTime.parse(saved!.values['Check out']!),
                );
        }),
      );
    }
    final awaitingCheckIn = !manager && started == null;
    final displayed = tab == 1
        ? visits
        : tab == 2 || manager
        ? reports
        : visits.where((visit) => !visit.completed);
    return Scaffold(
      appBar: AppBar(
        title: const Brand(),
        actions: [
          if (tab == 1)
            IconButton(
              tooltip: 'Daily plan table',
              icon: const Icon(Icons.table_chart_outlined),
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => TableReportPage(
                    title: 'Daily plan',
                    records: [
                      for (final visit in displayed)
                        {
                          'Name': visit.doctor,
                          'Time': visit.time,
                          'Clinic': visit.clinic,
                        },
                    ],
                  ),
                ),
              ),
            ),
          if (tab == 1 || tab == 2)
            ReportShareButton(
              title: tab == 1 ? 'Daily plan' : 'Visit reports',
              records: [
                for (final visit in displayed)
                  {
                    'Doctor': visit.doctor,
                    'Clinic': visit.clinic,
                    'Time': visit.time,
                    'Status': visit.completed ? 'Completed' : 'Planned',
                    'Summary': visit.notes,
                    ...visit.details,
                    if (visit.escalated) 'Manager follow-up': 'Required',
                  },
              ],
            ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      bottomNavigationBar: awaitingCheckIn
          ? null
          : NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (value) {
                if (value == 3) {
                  openModules();
                  return;
                }
                setState(() => tab = value);
              },
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: 'Today',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  label: 'Plan',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.assignment_outlined),
                  label: 'Reports',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'More',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
      body: role == Role.ceo && tab == 0
          ? CeoDashboard(
              reports: widget.reports,
              visits: widget.repository,
              onAttendance: ended == null ? recordAttendance : null,
              attendanceLabel: ended != null
                  ? 'Day ended at '
                  : started == null
                  ? 'Start of the day'
                  : 'End of the day',
            )
          : tab == 2
          ? ReportsDashboard(
              repository: widget.reports,
              visits: widget.repository,
            )
          : tab == 4
          ? ProfilePage(
              username: username,
              details: profileDetails[username],
              visits: widget.repository,
              onEdit: (value) =>
                  setState(() => profileDetails[username] = value),
              repository: widget.reports,
              role: role!,
              mode: widget.mode,
              onModeChanged: widget.onModeChanged,
              onSignOut: signOut,
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  key: ValueKey(tab),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    if (tab == 0) ...[
                      Container(
                        padding: const EdgeInsets.all(23),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [ink, medicalTeal],
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              manager
                                  ? Icons.groups_outlined
                                  : Icons.medical_services_outlined,
                              color: gold,
                              size: 34,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              profileDetails[username]?.$1 ?? username,
                              style: theme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              manager ? 'Team overview' : 'Your field day',
                              style: theme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              manager
                                  ? '${reports.length} visit reports in this workspace'
                                  : ended != null
                                  ? 'Day ended at ${ended!.format(context)}'
                                  : started != null
                                  ? 'Checked in at ${started!.format(context)}'
                                  : 'Check in to start your day.',
                              style: const TextStyle(color: tealTint),
                            ),
                            if (ended == null) ...[
                              const SizedBox(height: 12),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: tealTint,
                                  foregroundColor: ink,
                                ),
                                onPressed: recordAttendance,
                                child: Text(
                                  started == null ? 'Check in' : 'Check out',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!awaitingCheckIn) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              avatar: const Icon(
                                Icons.event_available_outlined,
                                size: 18,
                              ),
                              label: Text(
                                '${visits.length - reports.length} planned',
                              ),
                            ),
                            Chip(
                              avatar: const Icon(Icons.task_alt, size: 18),
                              label: Text('${reports.length} completed'),
                            ),
                            if (manager)
                              Chip(
                                avatar: const Icon(
                                  Icons.flag_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  '${reports.where((visit) => visit.escalated).length} need follow-up',
                                ),
                              ),
                          ],
                        ),

                        if (!manager) ...[
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: addVisit,
                            icon: const Icon(Icons.add),
                            label: const Text('Record a visit'),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ],
                    if (!awaitingCheckIn) ...[
                      Text(
                        tab == 1
                            ? 'Daily plan'
                            : tab == 2 || manager
                            ? 'Visit reports'
                            : 'Upcoming visits',
                        style: theme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (displayed.isEmpty)
                        const Panel(
                          child: ListTile(title: Text('No visit reports yet')),
                        ),
                      for (final visit in displayed)
                        Panel(
                          child: ListTile(
                            leading: Icon(
                              visit.escalated
                                  ? Icons.flag_outlined
                                  : Icons.local_hospital_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(visit.doctor),
                            subtitle: Text(
                              [
                                visit.clinic,
                                visit.time,
                                if (visit.notes.isNotEmpty) visit.notes,
                                if (visit.escalated) 'Manager follow-up needed',
                              ].join('\n'),
                            ),
                            trailing: visit.completed
                                ? const Icon(Icons.chevron_right)
                                : null,
                            onTap: visit.completed
                                ? () => showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    showDragHandle: true,
                                    builder: (_) => DraggableScrollableSheet(
                                      expand: false,
                                      initialChildSize: 0.78,
                                      maxChildSize: 0.95,
                                      builder: (context, controller) =>
                                          VisitReportDetails(
                                            visit: visit,
                                            controller: controller,
                                          ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

class Brand extends StatelessWidget {
  const Brand({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Image(
          image: AssetImage('assets/images/ipc_logo.jpeg'),
          width: 42,
          height: 42,
          fit: BoxFit.cover,
        ),
      ),
      SizedBox(width: 10),
      Text(
        'Aesthetic Daily',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}

class VisitForm extends StatefulWidget {
  const VisitForm({super.key});

  @override
  State<VisitForm> createState() => _VisitFormState();
}

class _VisitFormState extends State<VisitForm> {
  final form = GlobalKey<FormState>();
  String doctor = '';
  String clinic = '';
  String notes = '';
  bool escalated = false;

  Widget requiredField(String label, ValueChanged<String> save) =>
      TextFormField(
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
        onSaved: (value) => save(value!.trim()),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Record a visit')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: form,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                requiredField('Doctor name', (value) => doctor = value),
                const SizedBox(height: 14),
                requiredField('Clinic name', (value) => clinic = value),
                const SizedBox(height: 14),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Discussion summary',
                  ),
                  maxLines: 4,
                  onSaved: (value) => notes = value?.trim() ?? '',
                ),
                const SizedBox(height: 14),
                Panel(
                  child: SwitchListTile(
                    title: const Text('Manager follow-up needed'),
                    value: escalated,
                    onChanged: (value) => setState(() => escalated = value),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    if (!form.currentState!.validate()) return;
                    form.currentState!.save();
                    Navigator.pop(
                      context,
                      Visit(
                        doctor,
                        clinic,
                        TimeOfDay.now().format(context),
                        notes: notes,
                        escalated: escalated,
                        completed: true,
                      ),
                    );
                  },
                  child: const Text('Save visit'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

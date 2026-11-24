import 'package:flutter/material.dart';

import '../domain/orders.dart';
import '../domain/visits.dart';
import 'order_table.dart';

class VisitReportForm extends StatefulWidget {
  const VisitReportForm({super.key});

  @override
  State<VisitReportForm> createState() => _VisitReportFormState();
}

class _VisitReportFormState extends State<VisitReportForm> {
  final form = GlobalKey<FormState>();
  final data = <String, String>{};
  final controllers = <String, TextEditingController>{};
  final selected = <String, Set<String>>{};
  DateTime? nextVisit;
  bool managerNeeded = false;
  List<Map<String, String>> orderItems = [];
  int page = 0;

  Set<String> values(String key) => selected.putIfAbsent(key, () => {});

  TextEditingController controller(String key) =>
      controllers.putIfAbsent(key, TextEditingController.new);

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 10),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    ),
  );

  Widget field(String key, {bool required = false, int lines = 1}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      decoration: InputDecoration(labelText: key),
      controller: controller(key),
      maxLines: lines,
      onSaved: (value) => data[key] = value?.trim() ?? '',
      validator: required
          ? (value) => value == null || value.trim().isEmpty ? 'Required' : null
          : null,
    ),
  );

  Widget single(String key, List<String> options) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      initialValue: data[key]?.isEmpty == false ? data[key] : null,
      decoration: InputDecoration(labelText: key),
      isExpanded: true,
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: (value) => data[key] = value ?? '',
    ),
  );

  Widget multiple(String key, List<String> options) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(key, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in options)
            FilterChip(
              label: Text(option),
              selected: values(key).contains(option),
              onSelected: (active) => setState(() {
                active ? values(key).add(option) : values(key).remove(option);
              }),
            ),
        ],
      ),
      const SizedBox(height: 16),
    ],
  );

  void save() {
    if (!form.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete the required fields first.')),
      );
      return;
    }
    form.currentState!.save();
    for (final entry in controllers.entries) {
      data[entry.key] = entry.value.text.trim();
    }
    final doctor = controller('Doctor Name').text.trim();
    final clinic = controller('Clinic Name').text.trim();
    if (doctor.isEmpty || clinic.isEmpty) {
      setState(() => page = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doctor name and clinic name are required.'),
        ),
      );
      return;
    }
    final details = <String, String>{
      ...data,
      for (final entry in selected.entries)
        if (entry.value.isNotEmpty) entry.key: entry.value.join(', '),
      if (nextVisit != null)
        'Next Proposed Visit': nextVisit!.toIso8601String(),
      if (orderItems.isNotEmpty) ...{
        'Order items': encodeOrder(orderItems),
        'Order Total': orderTotal(orderItems).toStringAsFixed(2),
      },
    };
    Navigator.pop(
      context,
      Visit(
        doctor,
        clinic,
        TimeOfDay.now().format(context),
        notes: data['Discussion Notes'] ?? '',
        details: details,
        escalated: managerNeeded,
        completed: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Visit report')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Form(
            key: form,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    for (var index = 0; index < 3; index++) ...[
                      Expanded(
                        child: LinearProgressIndicator(
                          value: index <= page ? 1 : 0,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      if (index < 2) const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text('Page ${page + 1} of 3'),
                if (page == 0) ...[
                  heading('Waiting time activities'),
                  multiple('Visit Objectives', [
                    'Product Introduction',
                    'Follow-up',
                    'Handling Collection',
                    'Handling Complaint',
                    'Order Request',
                  ]),
                  single('Visit Type', ['Single', 'Double']),
                  multiple('Visit With', [
                    'Product Specialist',
                    'Senior Product Specialist',
                    'Product Supervisor',
                    'Product Manager',
                    'Area Manager',
                    'Marketing Director',
                    'Scientific Director',
                    'CEO',
                    'Others',
                  ]),

                  heading('Doctor information'),
                  field('Doctor Name', required: true),
                  single('Specialty', [
                    'Dermatology',
                    'Plastic Surgery',
                    'Dentist',
                  ]),
                  single('Class', ['Class A', 'Class B', 'Class C']),
                  field('Doctor Phone'),
                  field('Doctor Email'),
                  field('Doctor Address'),

                  heading('Clinic information'),
                  field('Clinic Name', required: true),
                  single('Clinic Type', ['Solo', 'Chain']),
                  field('Chain Number'),
                  for (final role in ['Owner', 'Accountant', 'Assistant']) ...[
                    field('$role Name'),
                    field('$role Phone'),
                  ],

                  heading('Doctor status'),
                  single('Doctor Status', [
                    'Active Doctor',
                    'Potential Doctor',
                    'New Doctor',
                    'Lost Doctor',
                  ]),
                  multiple('New Doctor Source', [
                    'Rep Visit',
                    'Medical Conferences & Events',
                    'Workshop & Lectures',
                    'Digital Marketing & Social Media',
                    'Word Of Mouth',
                    'Patient Request',
                  ]),
                  multiple('Lost Doctor Reasons', [
                    'High Price',
                    'Quality Results',
                    'Service Request',
                    'Trainer',
                  ]),
                ],

                if (page == 1) ...[
                  heading('Promoted products and feedback'),
                  multiple('Promoted Products', [
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
                  ]),
                  multiple('Doctor Feedback', [
                    'Satisfied',
                    'Price Concern',
                    'Performance Concerns',
                    'Other Concerns',
                  ]),
                  multiple('VIVACY Competitors', [
                    'Juvéderm',
                    'Restylane',
                    'Teosyal',
                    'Neauvia',
                    'Belotero',
                  ]),
                  multiple('BLOOM Competitors', [
                    'Rejuran Healer',
                    'Celosome',
                    'Humedix (Elravie)',
                  ]),

                  heading('Service and discussion'),
                  multiple('Service Request', [
                    'IMCAS',
                    'Factory Visit',
                    'Cadaver Masterclass',
                    'Stand Alone',
                    'Local Masterclass',
                    'Trainer',
                    'Clinic Workshop & Seminar',
                    'Photo Session Professional',
                    'Digital Marketing',
                  ]),
                  multiple('Discussion Summary', [
                    'Order Placed',
                    'More Follow-up',
                    'Problem Solved',
                    'Collection Solved',
                  ]),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Manager needed'),
                    subtitle: const Text('Send a follow-up notification'),
                    value: managerNeeded,
                    onChanged: (value) => setState(() => managerNeeded = value),
                  ),
                  single('Issues & Complaints', ['No', 'Yes']),
                  multiple('Issue Description', [
                    'Offer Needed',
                    'Cash back / Bonus',
                    'Scientific Events',
                    'Collection Issues',
                    'Product concerns',
                    'Activities',
                  ]),
                  field('Discussion Notes', lines: 4),
                ],

                if (page == 2) ...[
                  heading('Order and follow-up'),
                  OrderItemsEditor(
                    lines: orderItems,
                    onChanged: (value) => setState(() => orderItems = value),
                  ),
                  const SizedBox(height: 16),
                  field('Delivery Notes', lines: 3),
                  single('Payment Method', [
                    'Cash',
                    'InstaPay',
                    'Cheque 1m',
                    'Cheque 2m',
                    'Cheque 3m',
                    'Credit 1m',
                    'Credit 2m',
                    'Credit 3m',
                  ]),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      nextVisit == null
                          ? 'Select next proposed visit'
                          : nextVisit!.toString().substring(0, 16),
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (!context.mounted || date == null) return;
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(
                          () => nextVisit = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  multiple('Planned vs Delayed', [
                    'Doctor Apologized',
                    'Overtime with Previous Visit',
                    'Car Breakdown',
                    'Traffic Accident',
                    'Others',
                  ]),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (page > 0)
                      OutlinedButton.icon(
                        onPressed: () => setState(() => page--),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                      ),
                    if (page > 0) const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: page == 2
                            ? save
                            : () {
                                if (page == 0 &&
                                    !form.currentState!.validate()) {
                                  return;
                                }
                                form.currentState!.save();
                                setState(() => page++);
                              },
                        icon: Icon(
                          page == 2 ? Icons.save_outlined : Icons.arrow_forward,
                        ),
                        label: Text(page == 2 ? 'Save visit report' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

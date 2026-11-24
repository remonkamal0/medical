import 'package:flutter/material.dart';
import '../domain/orders.dart';
import '../domain/reports.dart';
import 'report_share.dart';

class OrderTable extends StatelessWidget {
  const OrderTable({super.key, required this.record});
  final Map<String, String> record;

  @override
  Widget build(BuildContext context) {
    final lines = orderLines(record);
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order placed',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ReportShareButton(
                  title: 'Order report',
                  records: [
                    {'Report type': 'Orders', ...record},
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(
                  colors.primaryContainer,
                ),
                columns: [
                  for (final column in orderColumns)
                    DataColumn(
                      label: Text(column),
                      numeric: column != 'Product',
                    ),
                ],
                rows: [
                  for (final line in lines)
                    DataRow(
                      cells: [
                        for (final column in orderColumns)
                          DataCell(Text(line[column] ?? '')),
                      ],
                    ),
                ],
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total value',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  orderTotal(lines).toStringAsFixed(2),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            for (final key in [
              'Payment method',
              'Delivery notes',
              'Employee',
              'Report date',
            ])
              if ((record[key] ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('$key: ${record[key]}'),
                ),
          ],
        ),
      ),
    );
  }
}

class OrderItemsEditor extends StatelessWidget {
  const OrderItemsEditor({
    super.key,
    required this.lines,
    required this.onChanged,
  });

  final List<Map<String, String>> lines;
  final ValueChanged<List<Map<String, String>>> onChanged;

  Future<void> addProduct(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _OrderLineDialog(),
    );
    if (result != null) onChanged([...lines, result]);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (lines.isNotEmpty) ...[
        OrderTable(record: {'Order items': encodeOrder(lines)}),
        for (var index = 0; index < lines.length; index++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(lines[index]['Product'] ?? ''),
            subtitle: Text(
              'Quantity ${lines[index]['Quantity']} · Total ${lines[index]['Total value']}',
            ),
            trailing: IconButton(
              tooltip: 'Remove item',
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                final updated = [...lines]..removeAt(index);
                onChanged(updated);
              },
            ),
          ),
      ],
      OutlinedButton.icon(
        onPressed: () => addProduct(context),
        icon: const Icon(Icons.add_shopping_cart_outlined),
        label: Text(lines.isEmpty ? 'Add first product' : 'Add another product'),
      ),
    ],
  );
}

class _OrderLineDialog extends StatefulWidget {
  const _OrderLineDialog();

  @override
  State<_OrderLineDialog> createState() => _OrderLineDialogState();
}

class _OrderLineDialogState extends State<_OrderLineDialog> {
  final key = GlobalKey<FormState>();
  final product = TextEditingController();
  final quantity = TextEditingController(text: '1');
  final bonus = TextEditingController(text: '0');
  final price = TextEditingController();
  final discount = TextEditingController(text: '0');

  @override
  void dispose() {
    product.dispose();
    quantity.dispose();
    bonus.dispose();
    price.dispose();
    discount.dispose();
    super.dispose();
  }

  String? requiredNumber(String? value) =>
      double.tryParse(value ?? '') == null ? 'Enter a valid number' : null;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add product'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: key,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: product,
                decoration: const InputDecoration(labelText: 'Product name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Product name is required'
                    : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numberField(quantity, 'Quantity')),
                  const SizedBox(width: 10),
                  Expanded(child: _numberField(bonus, 'Bonus')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _numberField(price, 'Unit price')),
                  const SizedBox(width: 10),
                  Expanded(child: _numberField(discount, 'Discount %')),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!key.currentState!.validate()) return;
          final qty = double.parse(quantity.text);
          final unitPrice = double.parse(price.text);
          final discountValue = double.parse(discount.text);
          final total = qty * unitPrice * (1 - discountValue / 100);
          Navigator.pop(context, {
            'Product': product.text.trim(),
            'Quantity': quantity.text.trim(),
            'Bonus': bonus.text.trim(),
            'Unit price': price.text.trim(),
            'Discount %': discount.text.trim(),
            'Total value': total.toStringAsFixed(2),
          });
        },
        child: const Text('Add'),
      ),
    ],
  );

  Widget _numberField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: requiredNumber,
      );
}

class OrderForm extends StatefulWidget {
  const OrderForm({super.key, required this.lineBuilder});
  final WidgetBuilder lineBuilder;

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final lines = <Map<String, String>>[];
  final form = GlobalKey<FormState>();
  String? payment;
  String notes = '';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New order')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (lines.isNotEmpty)
            OrderTable(record: {'Order items': encodeOrder(lines)}),
          for (var index = 0; index < lines.length; index++)
            ListTile(
              title: Text(lines[index]['Product'] ?? ''),
              trailing: IconButton(
                tooltip: 'Remove item',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => lines.removeAt(index)),
              ),
            ),
          OutlinedButton.icon(
            onPressed: () async {
              final entry = await Navigator.push<ReportEntry>(
                context,
                MaterialPageRoute(builder: widget.lineBuilder),
              );
              if (mounted && entry != null) {
                setState(() => lines.add(entry.values));
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add product'),
          ),
          const SizedBox(height: 16),
          Form(
            key: form,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Payment method',
                  ),
                  items: [
                    for (final value in [
                      'Cash',
                      'InstaPay',
                      'Cheque · 1 month',
                      'Cheque · 2 months',
                      'Cheque · 3 months',
                      'Credit · 1 month',
                      'Credit · 2 months',
                      'Credit · 3 months',
                    ])
                      DropdownMenuItem(value: value, child: Text(value)),
                  ],
                  onChanged: (value) => payment = value,
                  validator: (value) =>
                      value == null ? 'Choose a payment method' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Delivery notes',
                  ),
                  onChanged: (value) => notes = value.trim(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: lines.isEmpty
                ? null
                : () {
                    if (!form.currentState!.validate()) return;
                    Navigator.pop(
                      context,
                      ReportEntry({
                        'Product': lines
                            .map((line) => line['Product'])
                            .join(', '),
                        'Order items': encodeOrder(lines),
                        'Total value': orderTotal(lines).toStringAsFixed(2),
                        'Payment method': payment!,
                        'Delivery notes': notes,
                      }),
                    );
                  },
            child: const Text('Save order'),
          ),
        ],
      ),
    ),
  );
}

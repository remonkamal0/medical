import 'dart:convert';

const orderColumns = [
  'Product',
  'Quantity',
  'Bonus',
  'Unit price',
  'Discount %',
  'Total value',
];

List<Map<String, String>> orderLines(Map<String, String> record) {
  final encoded = record['Order items'];
  if (encoded == null) return [record];
  return (jsonDecode(encoded) as List)
      .map((line) => Map<String, String>.from(line as Map))
      .toList();
}

double orderTotal(List<Map<String, String>> lines) => lines.fold(
  0,
  (sum, line) => sum + (double.tryParse(line['Total value'] ?? '') ?? 0),
);

String encodeOrder(List<Map<String, String>> lines) => jsonEncode(lines);

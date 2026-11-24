import 'package:flutter/material.dart';
import 'report_share.dart';

class TableReportPage extends StatelessWidget {
  const TableReportPage({
    super.key,
    required this.title,
    required this.records,
  });
  final String title;
  final List<Map<String, String>> records;

  @override
  Widget build(BuildContext context) {
    final columns = records.expand((record) => record.keys).toSet().toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ReportShareButton(title: title, records: records, tabular: true),
        ],
      ),
      body: records.isEmpty
          ? const Center(child: Text('No records to display'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.primaryContainer,
                  ),
                  columns: [
                    for (final column in columns)
                      DataColumn(label: Text(column)),
                  ],
                  rows: [
                    for (final record in records)
                      DataRow(
                        cells: [
                          for (final column in columns)
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  record[column] ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

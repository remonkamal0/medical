import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;

import '../domain/orders.dart';
import '../features/reports/data/services/printing_report_exporter.dart';
import '../features/reports/domain/services/report_exporter.dart';

class ReportShareButton extends StatefulWidget {
  const ReportShareButton({
    super.key,
    required this.title,
    required this.records,
    this.tabular = true,
    this.iconColor,
    this.exporter = const PrintingReportExporter(),
  });

  final bool tabular;
  final String title;
  final List<Map<String, String>> records;
  final Color? iconColor;
  final ReportExporter exporter;

  @override
  State<ReportShareButton> createState() => _ReportShareButtonState();
}

class _ReportShareButtonState extends State<ReportShareButton> {
  static final navy = PdfColor.fromHex('#102F3F');
  static final mint = PdfColor.fromHex('#E7F5F2');
  static final rose = PdfColor.fromHex('#F7E7E7');
  static final border = PdfColor.fromHex('#D5E2E5');

  pdf.Widget orderBlock(Map<String, String> record) {
    final lines = orderLines(record);
    const headers = [
      'Product Name',
      'Quantity',
      'Bonus',
      'Price',
      'Discount',
      'Total Value',
    ];
    return pdf.Container(
      margin: const pdf.EdgeInsets.only(bottom: 22),
      decoration: pdf.BoxDecoration(
        border: pdf.Border.all(color: border),
        borderRadius: pdf.BorderRadius.circular(8),
      ),
      child: pdf.Column(
        crossAxisAlignment: pdf.CrossAxisAlignment.stretch,
        children: [
          pdf.Container(
            padding: const pdf.EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: pdf.BoxDecoration(
              color: navy,
              borderRadius: const pdf.BorderRadius.only(
                topLeft: pdf.Radius.circular(8),
                topRight: pdf.Radius.circular(8),
              ),
            ),
            child: pdf.Text(
              'ORDER PLACED',
              style: pdf.TextStyle(
                color: PdfColors.white,
                fontSize: 16,
                fontWeight: pdf.FontWeight.bold,
              ),
            ),
          ),
          pdf.TableHelper.fromTextArray(
            headers: headers,
            data: [
              for (final line in lines)
                [
                  line['Product'] ?? '',
                  line['Quantity'] ?? '',
                  line['Bonus'] ?? '',
                  line['Unit price'] ?? '',
                  '${line['Discount %'] ?? '0'}%',
                  line['Total value'] ?? '',
                ],
            ],
            headerDecoration: pdf.BoxDecoration(color: mint),
            headerStyle: pdf.TextStyle(
              color: navy,
              fontSize: 9,
              fontWeight: pdf.FontWeight.bold,
            ),
            rowDecoration: const pdf.BoxDecoration(color: PdfColors.white),
            oddRowDecoration: pdf.BoxDecoration(color: rose),
            cellStyle: const pdf.TextStyle(fontSize: 9),
            cellPadding: const pdf.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 9,
            ),
            border: pdf.TableBorder(
              horizontalInside: pdf.BorderSide(color: border, width: .5),
            ),
          ),
          pdf.Container(
            padding: const pdf.EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            decoration: pdf.BoxDecoration(color: PdfColor.fromHex('#EEF2F3')),
            child: pdf.Row(
              mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
              children: [
                pdf.Text(
                  'TOTAL VALUE',
                  style: pdf.TextStyle(
                    color: navy,
                    fontWeight: pdf.FontWeight.bold,
                  ),
                ),
                pdf.Text(
                  orderTotal(lines).toStringAsFixed(2),
                  style: pdf.TextStyle(
                    color: navy,
                    fontSize: 17,
                    fontWeight: pdf.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pdf.Widget sectionTitle(String title) => pdf.Container(
    margin: const pdf.EdgeInsets.only(top: 12, bottom: 7),
    padding: const pdf.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: pdf.BoxDecoration(
      color: navy,
      borderRadius: pdf.BorderRadius.circular(5),
    ),
    child: pdf.Text(
      title.toUpperCase(),
      style: pdf.TextStyle(
        color: PdfColors.white,
        fontSize: 11,
        fontWeight: pdf.FontWeight.bold,
      ),
    ),
  );

  List<pdf.Widget> educationalActivityBlock(Map<String, String> record) {
    const activityRows = [
      ('Event', 'Company'),
      ('Region', 'Area'),
      ('Date', 'Product specialist'),
      ('Clinic / Center', 'Trainer name'),
      ('Event objective', 'Number of attendees'),
    ];
    const attendeeFields = [
      'Doctor name',
      'Mobile',
      'Speciality',
      'Birthday',
      'Clinic',
      'Email',
    ];
    final syringeEntries = record.entries
        .where((entry) => entry.key.startsWith('Syringes / '))
        .toList();
    final evaluationEntries = record.entries
        .where((entry) => entry.key.startsWith('Evaluation / '))
        .toList();
    final attendeeCount = int.tryParse(record['Number of attendees'] ?? '') ?? 0;

    return [
        pdf.Text(
          'EDUCATIONAL ACTIVITY REPORT',
          style: pdf.TextStyle(
            color: navy,
            fontSize: 20,
            fontWeight: pdf.FontWeight.bold,
          ),
        ),
        sectionTitle('Activity information'),
        pdf.TableHelper.fromTextArray(
          headers: const ['Field', 'Details', 'Field', 'Details'],
          data: [
            for (final row in activityRows)
              [
                row.$1,
                (record[row.$1] ?? '').isEmpty ? '—' : record[row.$1]!,
                row.$2,
                (record[row.$2] ?? '').isEmpty ? '—' : record[row.$2]!,
              ],
          ],
          headerDecoration: pdf.BoxDecoration(color: mint),
          headerStyle: pdf.TextStyle(
            color: navy,
            fontWeight: pdf.FontWeight.bold,
          ),
          oddRowDecoration: pdf.BoxDecoration(color: PdfColor.fromHex('#F5F8F9')),
          cellPadding: const pdf.EdgeInsets.all(7),
          border: pdf.TableBorder.all(color: border, width: .6),
        ),
        sectionTitle('Type & number of syringes used'),
        if (syringeEntries.isEmpty)
          pdf.Text('No syringes recorded.', style: const pdf.TextStyle(fontSize: 9))
        else
          pdf.TableHelper.fromTextArray(
            headers: const ['Product / Syringe', 'Quantity'],
            data: [
              for (final entry in syringeEntries)
                [entry.key.replaceFirst('Syringes / ', ''), entry.value],
            ],
            headerDecoration: pdf.BoxDecoration(color: navy),
            headerStyle: pdf.TextStyle(
              color: PdfColors.white,
              fontWeight: pdf.FontWeight.bold,
            ),
            oddRowDecoration: pdf.BoxDecoration(color: mint),
            cellPadding: const pdf.EdgeInsets.all(7),
            border: pdf.TableBorder.all(color: border, width: .6),
          ),
        sectionTitle('Attendees information'),
        pdf.TableHelper.fromTextArray(
          headers: const ['#', ...attendeeFields],
          data: [
            for (var index = 0; index < attendeeCount; index++)
              [
                '${index + 1}',
                for (final field in attendeeFields)
                  record['Attendee ${index + 1} / $field'] ?? '',
              ],
          ],
          headerDecoration: pdf.BoxDecoration(color: mint),
          headerStyle: pdf.TextStyle(
            color: navy,
            fontSize: 8,
            fontWeight: pdf.FontWeight.bold,
          ),
          cellStyle: const pdf.TextStyle(fontSize: 7.5),
          cellPadding: const pdf.EdgeInsets.all(5),
          border: pdf.TableBorder.all(color: border, width: .6),
        ),
        pdf.NewPage(),
        sectionTitle('Evaluation form'),
        pdf.TableHelper.fromTextArray(
          headers: const ['Item', 'Rating'],
          data: [
            for (final entry in evaluationEntries)
              [entry.key.replaceFirst('Evaluation / ', ''), entry.value],
          ],
          headerDecoration: pdf.BoxDecoration(color: navy),
          headerStyle: pdf.TextStyle(
            color: PdfColors.white,
            fontWeight: pdf.FontWeight.bold,
          ),
          oddRowDecoration: pdf.BoxDecoration(color: mint),
          cellPadding: const pdf.EdgeInsets.all(7),
          border: pdf.TableBorder.all(color: border, width: .6),
        ),
        pdf.SizedBox(height: 22),
      ];
  }

  bool sharing = false;

  List<pdf.Widget> reportTables(List<Map<String, String>> records) {
    final groups = <String, List<Map<String, String>>>{};
    for (final record in records) {
      (groups[record['Report type'] ?? widget.title] ??= []).add(record);
    }
    final widgets = <pdf.Widget>[];
    for (final group in groups.entries) {
      if (group.key == 'Workshops and seminars') {
        for (final record in group.value) {
          widgets.addAll(educationalActivityBlock(record));
        }
        continue;
      }
      if (group.key == 'Orders') {
        for (final record in group.value) {
          widgets.add(orderBlock(record));
          for (final key in [
            'Payment method',
            'Delivery notes',
            'Employee',
            'Report date',
          ]) {
            if ((record[key] ?? '').isNotEmpty) {
              widgets.add(pdf.Text('$key: ${record[key]}'));
            }
          }
          widgets.add(pdf.SizedBox(height: 20));
        }
        continue;
      }
      final columns = group.value
          .expand((record) => record.keys)
          .where((key) => key != 'Order items')
          .toSet()
          .toList();
      widgets.add(
        pdf.Text(
          group.key,
          style: pdf.TextStyle(fontSize: 13, fontWeight: pdf.FontWeight.bold),
        ),
      );
      for (var offset = 0; offset < columns.length; offset += 5) {
        final batch = columns.skip(offset).take(5).toList();
        widgets.add(pdf.SizedBox(height: 8));
        widgets.add(
          pdf.TableHelper.fromTextArray(
            headers: ['#', ...batch],
            data: [
              for (var index = 0; index < group.value.length; index++)
                [
                  '${index + 1}',
                  for (final column in batch) group.value[index][column] ?? '',
                ],
            ],
            headerDecoration: pdf.BoxDecoration(
              color: PdfColor.fromHex('#D8EFEB'),
            ),
            cellStyle: const pdf.TextStyle(fontSize: 9),
          ),
        );
      }
      widgets.add(pdf.SizedBox(height: 16));
      for (final record in group.value) {
        if ((record['Order items'] ?? '').isNotEmpty) {
          widgets.add(orderBlock(record));
        }
      }
    }
    return widgets;
  }

  Future<void> share() async {
    final records = widget.records;
    final title = widget.title;
    setState(() => sharing = true);
    try {
      pdf.MemoryImage? logo;
      try {
        final logoBytes = await rootBundle.load('assets/images/ipc_logo.jpeg');
        if (logoBytes.lengthInBytes > 0) {
          logo = pdf.MemoryImage(logoBytes.buffer.asUint8List());
        }
      } catch (_) {
        logo = null;
      }
      final document = pdf.Document(title: title, author: 'Aesthetic Daily');
      document.addPage(
        pdf.MultiPage(
          pageFormat: widget.tabular
              ? PdfPageFormat.a4.landscape
              : PdfPageFormat.a4,
          margin: const pdf.EdgeInsets.fromLTRB(30, 28, 30, 32),
          header: (_) => pdf.Container(
            margin: const pdf.EdgeInsets.only(bottom: 20),
            padding: const pdf.EdgeInsets.fromLTRB(18, 14, 18, 14),
            decoration: pdf.BoxDecoration(
              color: navy,
              borderRadius: pdf.BorderRadius.circular(10),
            ),
            child: pdf.Row(
              children: [
                pdf.Container(
                  width: 34,
                  height: 34,
                  decoration: pdf.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pdf.BorderRadius.circular(8),
                  ),
                  child: logo == null
                      ? pdf.Center(
                          child: pdf.Text(
                            'IPC',
                            style: pdf.TextStyle(
                              color: navy,
                              fontSize: 9,
                              fontWeight: pdf.FontWeight.bold,
                            ),
                          ),
                        )
                      : pdf.ClipRRect(
                          horizontalRadius: 8,
                          verticalRadius: 8,
                          child: pdf.Image(logo, fit: pdf.BoxFit.cover),
                        ),
                ),
                pdf.SizedBox(width: 12),
                pdf.Column(
                  crossAxisAlignment: pdf.CrossAxisAlignment.start,
                  children: [
                    pdf.Text(
                      'AESTHETIC DAILY',
                      style: pdf.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                        fontWeight: pdf.FontWeight.bold,
                      ),
                    ),
                    pdf.Text(
                      title,
                      style: pdf.TextStyle(
                        color: PdfColors.white,
                        fontSize: 17,
                        fontWeight: pdf.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          footer: (context) => pdf.Align(
            alignment: pdf.Alignment.centerRight,
            child: pdf.Text(
              'Aesthetic Daily  •  ${context.pageNumber} / ${context.pagesCount}',
              style: pdf.TextStyle(color: PdfColors.grey600, fontSize: 8),
            ),
          ),
          build: (_) => [
            if (widget.tabular)
              ...reportTables(records)
            else
              for (final record in records) ...[
                for (final field in record.entries)
                  if (field.value.trim().isNotEmpty)
                    for (final line in field.value.split(RegExp(r'\r?\n')))
                      for (final chunk in RegExp(
                        r'.{1,250}',
                        unicode: true,
                      ).allMatches(line))
                        pdf.Padding(
                          padding: const pdf.EdgeInsets.only(bottom: 5),
                          child: pdf.Text('${field.key}: ${chunk.group(0)}'),
                        ),
                pdf.Divider(color: PdfColors.grey300),
              ],
          ],
        ),
      );
      final bytes = await document.save();
      final filename =
          'aesthetic-daily-${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}.pdf';
      await widget.exporter.export(
        bytes: bytes,
        filename: filename,
        landscape: widget.tabular,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open the PDF: $error'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Open PDF',
    icon: sharing
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(Icons.picture_as_pdf_outlined, color: widget.iconColor),
    onPressed: sharing || widget.records.isEmpty ? null : share,
  );
}

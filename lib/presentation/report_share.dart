import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';

class ReportShareButton extends StatefulWidget {
  const ReportShareButton({
    super.key,
    required this.title,
    required this.records,
    this.tabular = true,
  });

  final bool tabular;
  final String title;
  final List<Map<String, String>> records;

  @override
  State<ReportShareButton> createState() => _ReportShareButtonState();
}

class _ReportShareButtonState extends State<ReportShareButton> {
  bool sharing = false;

  List<pdf.Widget> reportTables(List<Map<String, String>> records) {
    final groups = <String, List<Map<String, String>>>{};
    for (final record in records) {
      (groups[record['Report type'] ?? widget.title] ??= []).add(record);
    }
    final widgets = <pdf.Widget>[];
    for (final group in groups.entries) {
      final columns = group.value
          .expand((record) => record.keys)
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
    }
    return widgets;
  }

  Future<void> share() async {
    final box = context.findRenderObject();
    final bounds = box is RenderBox
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    final records = widget.records;
    final title = widget.title;
    setState(() => sharing = true);
    try {
      final document = pdf.Document(title: title, author: 'Aesthetic Daily');
      document.addPage(
        pdf.MultiPage(
          pageFormat: widget.tabular
              ? PdfPageFormat.a4.landscape
              : PdfPageFormat.a4,
          header: (_) => pdf.Padding(
            padding: const pdf.EdgeInsets.only(bottom: 18),
            child: pdf.Text(
              'Aesthetic Daily | $title',
              style: pdf.TextStyle(
                fontSize: 17,
                color: PdfColor.fromHex('#0F766E'),
              ),
            ),
          ),
          footer: (context) => pdf.Align(
            alignment: pdf.Alignment.centerRight,
            child: pdf.Text('${context.pageNumber} / ${context.pagesCount}'),
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
      await Printing.sharePdf(
        bytes: await document.save(),
        filename:
            'aesthetic-daily-${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}.pdf',
        bounds: bounds,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not share the PDF on this device.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Share PDF',
    icon: sharing
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.ios_share),
    onPressed: sharing || widget.records.isEmpty ? null : share,
  );
}

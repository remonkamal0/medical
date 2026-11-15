import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';

class ReportShareButton extends StatefulWidget {
  const ReportShareButton({
    super.key,
    required this.title,
    required this.records,
  });

  final String title;
  final List<Map<String, String>> records;

  @override
  State<ReportShareButton> createState() => _ReportShareButtonState();
}

class _ReportShareButtonState extends State<ReportShareButton> {
  bool sharing = false;

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
          pageFormat: PdfPageFormat.a4,
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

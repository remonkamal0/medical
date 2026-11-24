import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../domain/services/report_exporter.dart';

class PrintingReportExporter implements ReportExporter {
  const PrintingReportExporter();

  @override
  Future<void> export({
    required Uint8List bytes,
    required String filename,
    required bool landscape,
  }) async {
    final capabilities = await Printing.info();
    var opened = false;
    if (capabilities.canShare) {
      try {
        opened = await Printing.sharePdf(bytes: bytes, filename: filename);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened) {
      opened = await Printing.layoutPdf(
        name: filename,
        format: landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
        dynamicLayout: false,
        onLayout: (_) async => bytes,
      );
    }
    if (!opened) throw StateError('PDF viewer is not available.');
  }
}

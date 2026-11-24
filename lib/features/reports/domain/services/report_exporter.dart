import 'dart:typed_data';

abstract interface class ReportExporter {
  Future<void> export({
    required Uint8List bytes,
    required String filename,
    required bool landscape,
  });
}

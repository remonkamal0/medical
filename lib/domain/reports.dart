class ReportEntry {
  const ReportEntry(this.values);
  final Map<String, String> values;
}

abstract interface class ReportRepository {
  List<ReportEntry> list(String section);
  void add(String section, ReportEntry entry);
}

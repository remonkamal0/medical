import 'data/demo_auth.dart';
import 'data/demo_reports.dart';
import 'package:flutter/material.dart';
import 'data/demo_visits.dart';
import 'presentation/app.dart';

void main() => runApp(
  MedicalApp(
    repository: DemoVisitRepository(),
    reports: DemoReportRepository(),
    auth: DemoAuthRepository(),
  ),
);

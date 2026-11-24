import 'data/demo_auth.dart';
import 'data/demo_reports.dart';
import 'package:flutter/material.dart';
import 'data/demo_visits.dart';
import 'presentation/app.dart';
import 'core/di/app_dependencies.dart';

void main() => runApp(
  MedicalApp(
    dependencies: AppDependencies(
      visitRepository: DemoVisitRepository(),
      reportRepository: DemoReportRepository(),
      authRepository: DemoAuthRepository(),
    ),
  ),
);

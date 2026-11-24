import 'package:medical/data/demo_auth.dart';
import 'package:medical/data/demo_reports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical/data/demo_visits.dart';
import 'package:medical/presentation/app.dart';
import 'package:medical/core/di/app_dependencies.dart';

void main() {
  testWidgets('A recorded visit appears in manager reports', (tester) async {
    await tester.pumpWidget(
      MedicalApp(
        dependencies: AppDependencies(
          visitRepository: DemoVisitRepository(),
          reportRepository: DemoReportRepository(),
          authRepository: DemoAuthRepository(),
        ),
      ),
    );
    await signIn(tester, 'rep', 'Rep1234');
    await tester.pumpAndSettle();
    expect(find.text('Record a visit'), findsNothing);
    await tester.tap(find.text('Check in'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Cairo office');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record a visit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Dr. Test');
    await tester.enterText(find.byType(TextFormField).at(1), 'Test clinic');
    await tester.tap(find.text('Save visit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();
    await signIn(tester, 'manager', 'Manager1234');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reports').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Dr. Test'), findsOneWidget);
  });
}

Future<void> signIn(
  WidgetTester tester,
  String username,
  String password,
) async {
  await tester.enterText(find.byType(TextField).at(0), username);
  await tester.enterText(find.byType(TextField).at(1), password);
  await tester.tap(find.text('Sign in'));
  await tester.pumpAndSettle();
}

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_user.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/usecases/report_use_cases.dart';
import '../../features/visits/domain/repositories/visit_repository.dart';
import '../../features/visits/domain/usecases/visit_use_cases.dart';

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.reportRepository,
    required this.visitRepository,
  });

  final AuthRepository authRepository;
  final ReportRepository reportRepository;
  final VisitRepository visitRepository;

  SignInUser get signInUser => SignInUser(authRepository);
  GetReports get getReports => GetReports(reportRepository);
  AddReport get addReport => AddReport(reportRepository);
  UpdateReport get updateReport => UpdateReport(reportRepository);
  GetVisits get getVisits => GetVisits(visitRepository);
  AddVisit get addVisit => AddVisit(visitRepository);
}

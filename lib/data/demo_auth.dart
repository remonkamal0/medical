import '../domain/auth.dart';
import '../domain/visits.dart';

class DemoAuthRepository implements AuthRepository {
  @override
  Role? signIn(String username, String password) =>
      switch ((username.trim().toLowerCase(), password)) {
        ('rep', 'Rep1234') => Role.rep,
        ('manager', 'Manager1234') => Role.manager,
        ('senior', 'Senior1234') => Role.senior,
        ('supervisor', 'Supervisor1234') => Role.supervisor,
        ('area', 'Area1234') => Role.areaManager,
        ('marketing', 'Marketing1234') => Role.marketingDirector,
        ('scientific', 'Scientific1234') => Role.scientificDirector,
        ('ceo', 'Ceo1234') => Role.ceo,
        _ => null,
      };
}

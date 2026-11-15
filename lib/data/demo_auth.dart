import '../domain/auth.dart';
import '../domain/visits.dart';

class DemoAuthRepository implements AuthRepository {
  @override
  Role? signIn(String username, String password) =>
      switch ((username.trim().toLowerCase(), password)) {
        ('rep', 'Rep1234') => Role.rep,
        ('manager', 'Manager1234') => Role.manager,
        _ => null,
      };
}

import 'package:flutter_test/flutter_test.dart';
import 'package:medical/features/auth/domain/repositories/auth_repository.dart';
import 'package:medical/features/auth/domain/usecases/sign_in_user.dart';
import 'package:medical/features/visits/domain/entities/role.dart';

void main() {
  test('sign in use case delegates authentication', () {
    const useCase = SignInUser(_FakeAuthRepository());

    expect(useCase('rep', 'valid'), Role.rep);
    expect(useCase('rep', 'invalid'), isNull);
  });
}

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository();

  @override
  Role? signIn(String username, String password) =>
      username == 'rep' && password == 'valid' ? Role.rep : null;
}

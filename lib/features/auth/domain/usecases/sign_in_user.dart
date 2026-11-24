import '../../../visits/domain/entities/role.dart';
import '../repositories/auth_repository.dart';

class SignInUser {
  const SignInUser(this.repository);
  final AuthRepository repository;

  Role? call(String username, String password) =>
      repository.signIn(username, password);
}

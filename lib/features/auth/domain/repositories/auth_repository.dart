import '../../../visits/domain/entities/role.dart';

abstract interface class AuthRepository {
  Role? signIn(String username, String password);
}

import 'visits.dart';

abstract interface class AuthRepository {
  Role? signIn(String username, String password);
}

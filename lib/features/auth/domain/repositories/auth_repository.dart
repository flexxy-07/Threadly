import 'package:threadly/core/type_defs.dart';
import 'package:threadly/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  FutureEither<User> signInWithGoogle();
}
import 'package:threadly/core/type_defs.dart';
import 'package:threadly/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  FutureEither<User> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });
  
  FutureEither<User> signInWithEmail({
    required String email,
    required String password,
  });
}
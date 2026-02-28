import 'package:threadly/core/type_defs.dart';
import 'package:threadly/features/auth/domain/entities/user.dart';
import 'package:threadly/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository authRepository;
  SignInWithGoogle({required this.authRepository});

  FutureEither<User> call() => authRepository.signInWithGoogle();
}
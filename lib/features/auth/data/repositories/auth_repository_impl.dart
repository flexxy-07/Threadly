import 'package:fpdart/fpdart.dart';
import 'package:threadly/core/common/failure.dart';
import 'package:threadly/core/type_defs.dart';
import 'package:threadly/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:threadly/features/auth/domain/entities/user.dart';
import 'package:threadly/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl({required this.remoteDatasource});

  @override
  FutureEither<User> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await remoteDatasource.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      return result.fold(
        (failure) => left(failure),
        (userModel) => right(userModel),
      );
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureEither<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDatasource.signInWithEmail(
        email: email,
        password: password,
      );
      return result.fold(
        (failure) => left(failure),
        (userModel) => right(userModel),
      );
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
import 'package:fpdart/fpdart.dart';
import 'package:threadly/core/common/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
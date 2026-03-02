import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:threadly/core/constants/constants.dart';
import 'package:threadly/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:threadly/features/auth/data/models/user_model.dart';
import 'package:threadly/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:threadly/features/auth/domain/entities/user.dart' as entity;

// ---------------------------------------------------------------------------
// Dependency providers
// ---------------------------------------------------------------------------

/// Notifier for the currently loaded [UserModel].
class UserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() => null;

  void setUser(UserModel? user) => state = user;
}

final userProvider = NotifierProvider<UserNotifier, UserModel?>(UserNotifier.new);

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

/// Exposes Supabase auth state changes as a stream.
final authStateChangeProvider = StreamProvider<User?>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange.map((data) => data.session?.user);
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    supabase: ref.watch(supabaseClientProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
  );
});

// ---------------------------------------------------------------------------
// Auth state provider
// ---------------------------------------------------------------------------

/// Exposes the currently signed-in [entity.User], or `null` when signed out.
/// The outer [AsyncValue] represents loading / error states during sign-in.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, entity.User?>(AuthController.new);

// ---------------------------------------------------------------------------
// Auth controller
// ---------------------------------------------------------------------------

class AuthController extends AsyncNotifier<entity.User?> {
  /// Called once when the provider is first read.
  /// Returns the user that is already signed-in via Supabase, or null.
  @override
  Future<entity.User?> build() async {
    final currentUser = ref.watch(supabaseClientProvider).auth.currentUser;
    if (currentUser == null) return null;
    return entity.User(
      uid: currentUser.id,
      name: currentUser.userMetadata?['name'] ?? '',
      email: currentUser.email ?? '',
      profilePic: Constants.avatarDefault,
    );
  }

  /// Signs up a new user with email and password.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signUpWithEmail(
      email: email,
      password: password,
      name: name,
    );
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (user) {
        ref.read(userProvider.notifier).setUser(user as UserModel);
        state = AsyncData(user);
      },
    );
  }

  /// Signs in an existing user with email and password.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signInWithEmail(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (user) {
        ref.read(userProvider.notifier).setUser(user as UserModel);
        state = AsyncData(user);
      },
    );
  }

  /// Signs the user out from Supabase.
  Future<void> signOut() async {
    state = const AsyncLoading();
    await ref.read(supabaseClientProvider).auth.signOut();
    ref.read(userProvider.notifier).setUser(null);
    state = const AsyncData(null);
  }
}
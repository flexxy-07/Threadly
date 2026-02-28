import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:threadly/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:threadly/features/auth/data/models/user_model.dart';
import 'package:threadly/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:threadly/features/auth/domain/entities/user.dart' as entity;
import 'package:threadly/features/auth/domain/usecases/sign_in_with_google.dart';

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

final firebaseAuthProvider = Provider<fb.FirebaseAuth>(
  (ref) => fb.FirebaseAuth.instance,
);

final firebaseFirestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final googleSignInProvider = Provider<GoogleSignIn>(
  (ref) => GoogleSignIn(
    clientId: kIsWeb ? dotenv.env['GOOGLE_WEB_CLIENT_ID'] : null,
  ),
);

/// Exposes Firebase auth state changes as a stream.
final authStateChangeProvider = StreamProvider<fb.User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
  );
});

final signInWithGoogleUsecaseProvider = Provider<SignInWithGoogle>((ref) {
  return SignInWithGoogle(authRepository: ref.watch(authRepositoryProvider));
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
  /// Returns the user that is already signed-in via Firebase, or null.
  @override
  Future<entity.User?> build() async {
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;
    if (currentUser == null) return null;
    return entity.User(
      uid: currentUser.uid,
      name: currentUser.displayName ?? '',
      email: currentUser.email ?? '',
      profilePic: currentUser.photoURL ?? '',
    );
  }

  /// Signs the user in with Google.
  /// Handles the [Either] result from the use case and updates [userProvider].
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await ref.read(signInWithGoogleUsecaseProvider).call();
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (user) {
        ref.read(userProvider.notifier).setUser(user as UserModel);
        state = AsyncData(user);
      },
    );
  }

  /// Signs the user out from both Google and Firebase.
  Future<void> signOut() async {
    state = const AsyncLoading();
    await ref.read(googleSignInProvider).signOut();
    await ref.read(firebaseAuthProvider).signOut();
    ref.read(userProvider.notifier).setUser(null);
    state = const AsyncData(null);
  }
}
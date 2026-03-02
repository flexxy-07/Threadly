import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:threadly/core/common/failure.dart';
import 'package:threadly/core/constants/constants.dart';
import 'package:threadly/core/constants/firebase_constants.dart';
import 'package:threadly/core/type_defs.dart';
import 'package:threadly/features/auth/data/models/user_model.dart';

class AuthRemoteDatasource {
  final SupabaseClient supabase;

  AuthRemoteDatasource({
    required this.supabase,
  });

  Stream<User?> get authStateChange => supabase.auth.onAuthStateChange.map((data) => data.session?.user);

  /// Sign up a new user with email and password
  FutureEither<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (authResponse.user == null) {
        return left(Failure('Failed to create account'));
      }

      final user = authResponse.user!;

      // Create user profile in database
      final userModel = UserModel(
        uid: user.id,
        email: user.email ?? email,
        name: name,
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        isAuthenticated: true,
        karma: 0,
        awards: [],
      );

      await supabase.from(DatabaseConstants.usersTable).insert(userModel.toMap());

      // Try to auto sign in after signup to establish a session
      // This works when email confirmation is disabled
      try {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        print('✅ User signed up and auto-signed in!');
        print('   Name  : ${userModel.name}');
        print('   Email : ${userModel.email}');
      } catch (signInError) {
        // Email confirmation is likely required
        print('⚠️ User created successfully!');
        print('   Please check your email (${email}) to confirm your account');
        print('   Error: ${signInError.toString()}');
      }

      return right(userModel);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Sign in an existing user with email and password
  FutureEither<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return left(Failure('Failed to sign in'));
      }

      final user = authResponse.user!;

      // Get user profile from database
      final userResponse = await supabase
          .from(DatabaseConstants.usersTable)
          .select()
          .eq('uid', user.id)
          .maybeSingle();

      if (userResponse == null) {
        return left(Failure('User profile not found'));
      }

      final userModel = UserModel.fromMap(userResponse);

      print('✅ User signed in successfully!');
      print('   Name  : ${userModel.name}');
      print('   Email : ${userModel.email}');

      return right(userModel);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return supabase
        .from(DatabaseConstants.usersTable)
        .stream(primaryKey: ['uid'])
        .eq('uid', uid)
        .map((data) {
          if (data.isEmpty) throw Exception('User not found');
          return UserModel.fromMap(data.first);
        });
  }
}

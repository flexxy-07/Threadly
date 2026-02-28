import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:threadly/core/constants/constants.dart';
import 'package:threadly/core/constants/firebase_constants.dart';
import 'package:threadly/core/type_defs.dart';
import 'package:threadly/features/auth/data/models/user_model.dart';

class AuthRemoteDatasource {
  final fb.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;

  AuthRemoteDatasource({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.firestore,
  });

  CollectionReference get _users =>
      firestore.collection(FirebaseConstants.usersCollection);

  Stream<fb.User?> get authStateChange => firebaseAuth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle() async {
    final googleUser = await googleSignIn.signIn();

    final googleAuth = await googleUser!.authentication;

    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebaseAuth.signInWithCredential(credential);

    final user = userCredential.user!;

    UserModel userModel;

    if (userCredential.additionalUserInfo!.isNewUser) {
      userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'No name',
        profilePic: user.photoURL ?? Constants.avatarDefault,
        banner: Constants.bannerDefault,
        isAuthenticated: true,
        karma: 0,
        awards: [],
      );
      await _users.doc(user.uid).set(userModel.toMap());
    } else {
      userModel = await getUserData(user.uid).first;
    }

    print('✅ User signed in successfully!');
    print('   Name  : ${user.displayName}');
    print('   Email : ${user.email}');

    return right(userModel);
  }

  Stream<UserModel> getUserData(String uid){
    return _users.doc(uid).snapshots().map((event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }
}

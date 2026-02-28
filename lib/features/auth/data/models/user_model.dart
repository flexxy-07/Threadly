import 'package:threadly/features/auth/domain/entities/user.dart';

class UserModel extends User {
  final String banner;
  final bool isAuthenticated;
  final int karma;
  final List<String> awards;
  UserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.profilePic,
    required this.banner,
    required this.isAuthenticated,
    required this.karma,
    required this.awards,
  });

  factory UserModel.fromFirebase(user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      name: user.displayName ?? '',
      profilePic: user.photoURL ?? '',
      banner: user.banner ?? '',
      isAuthenticated: user.isAuthenticated ?? false,
      karma: user.karma ?? 0,
      awards: user.awards ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profilePic': profilePic,
      'banner': banner,
      'isAuthenticated': isAuthenticated,
      'karma': karma,
      'awards': awards,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      banner: map['banner'] ?? '',
      isAuthenticated: map['isAuthenticated'] ?? false,
      karma: map['karma'] ?? 0,
      awards: List<String>.from(map['awards'] ?? []),
    );
  }
}

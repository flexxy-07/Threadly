// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class Community {
  final String name;
  final String title;
  final String banner;
  final String avatar;
  final List<String> members;
  final List<String> mods;

  Community({
    required this.name,
    required this.title,
    required this.banner,
    required this.avatar,
    required this.members,
    required this.mods,
  });

  Community copyWith({
    String? name,
    String? title,
    String? banner,
    String? avatar,
    List<String>? members,
    List<String>? mods,
  }) {
    return Community(
      name: name ?? this.name,
      title: title ?? this.title,
      banner: banner ?? this.banner,
      avatar: avatar ?? this.avatar,
      members: members ?? this.members,
      mods: mods ?? this.mods,
    );
  }

  /// Get banner URL with cache-bust parameter to force fresh load
  String getBannerUrl() {
    if (banner.isEmpty) return banner;
    // Check if URL already has a timestamp parameter
    if (banner.contains('v=')) {
      return banner; // Already has cache-bust parameter
    }
    // Add timestamp with proper separator (? or &)
    final separator = banner.contains('?') ? '&' : '?';
    return '$banner${separator}v=${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get avatar URL with cache-bust parameter to force fresh load
  String getAvatarUrl() {
    if (avatar.isEmpty) return avatar;
    // Check if URL already has a timestamp parameter
    if (avatar.contains('v=')) {
      return avatar; // Already has cache-bust parameter
    }
    // Add timestamp with proper separator (? or &)
    final separator = avatar.contains('?') ? '&' : '?';
    return '$avatar${separator}v=${DateTime.now().millisecondsSinceEpoch}';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'title': title,
      'banner': banner,
      'avatar': avatar,
      'members': members,
      'mods': mods,
    };
  }

  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      name: map['name'] as String,
      title: map['title'] as String,
      banner: map['banner'] as String? ?? '',
      avatar: map['avatar'] as String? ?? '',
      members: List<String>.from((map['members'] as List<dynamic>?) ?? []),
      mods: List<String>.from((map['mods'] as List<dynamic>?) ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Community.fromJson(String source) => Community.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Community(name: $name, title: $title, banner: $banner, avatar: $avatar, members: $members, mods: $mods)';
  }

  @override
  bool operator ==(covariant Community other) {
    if (identical(this, other)) return true;
  
    return 
      other.name == name &&
      other.title == title &&
      other.banner == banner &&
      other.avatar == avatar &&
      listEquals(other.members, members) &&
      listEquals(other.mods, mods);
  }

  @override
  int get hashCode {
    return name.hashCode ^
      title.hashCode ^
      banner.hashCode ^
      avatar.hashCode ^
      members.hashCode ^
      mods.hashCode;
  }
}

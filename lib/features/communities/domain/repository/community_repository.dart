import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:threadly/core/common/failure.dart';
import 'package:threadly/core/constants/firebase_constants.dart';
import 'package:threadly/core/type_defs.dart';
import 'package:threadly/features/auth/presentation/pages/providers/auth_controller.dart';
import 'package:threadly/features/communities/data/models/community_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(supabase: ref.watch(supabaseClientProvider));
});

class CommunityRepository {
  final SupabaseClient _supabase;
  CommunityRepository({required SupabaseClient supabase}) : _supabase = supabase;

  FutureVoid createCommunity(Community community) async {
    try {
      // Check if community already exists
      final existingCommunity = await _supabase
          .from(DatabaseConstants.communitiesTable)
          .select()
          .eq('name', community.name)
          .maybeSingle();

      if (existingCommunity != null) {
        throw 'Community with the same name already exists!';
      }

      await _supabase.from(DatabaseConstants.communitiesTable).insert(community.toMap());
      
      return right(null);
    } on PostgrestException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    return _supabase
        .from(DatabaseConstants.communitiesTable)
        .stream(primaryKey: ['name'])
        .map((data) {
          return data.where((community) {
            final members = community['members'] as List<dynamic>?;
            return members?.contains(uid) ?? false;
          }).map((e) => Community.fromMap(e)).toList();
        });
  }

  Stream<Community> getCommunityByName(String name) {
    return _supabase
        .from(DatabaseConstants.communitiesTable)
        .stream(primaryKey: ['name'])
        .eq('name', name)
        .map((data) {
          if (data.isEmpty) throw Exception('Community not found');
          return Community.fromMap(data.first);
        });
  }

  FutureVoid editCommunity(Community community) async {
    try {
      await _supabase
          .from(DatabaseConstants.communitiesTable)
          .update(community.toMap())
          .eq('name', community.name);
      
      return right(null);
    } on PostgrestException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      // First get the community to check current members
      final community = await _supabase
          .from(DatabaseConstants.communitiesTable)
          .select()
          .eq('name', communityName)
          .maybeSingle();

      if (community == null) {
        return left(Failure('Community not found'));
      }

      // Get current members array
      final members = List<dynamic>.from(community['members'] ?? []);

      // Check if user is already a member
      if (members.contains(userId)) {
        return left(Failure('You are already a member of this community'));
      }

      // Add user to members array
      members.add(userId);

      // Update the community with the new members list
      await _supabase
          .from(DatabaseConstants.communitiesTable)
          .update({'members': members})
          .eq('name', communityName);

      return right(null);
    } on PostgrestException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
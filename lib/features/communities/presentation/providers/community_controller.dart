import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:routemaster/routemaster.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:threadly/core/constants/constants.dart';
import 'package:threadly/core/providers/storage_providers.dart';
import 'package:threadly/core/utils.dart';
import 'package:threadly/features/auth/presentation/pages/providers/auth_controller.dart';
import 'package:threadly/features/communities/data/models/community_model.dart';
import 'package:threadly/features/communities/domain/repository/community_repository.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);

  return communityController.getUserCommunities();
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
      final communityRepository = ref.watch(communityRepositoryProvider);
      return CommunityController(
        communityRepository: communityRepository,
        ref: ref,
        storageRepository: ref.watch(storageRepositoryProvider),
        supabaseClient: ref.watch(supabaseClientProvider),
      );
    });

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  final communityController = ref.watch(communityControllerProvider.notifier);

  return communityController.getCommunityByName(name);
});

final searchCommunityProvider = FutureProvider.family((ref, String query) {
  final communityController = ref.watch(communityControllerProvider.notifier);

  return communityController.searchCommunities(query);
});


class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  final SupabaseClient _supabaseClient;
  
  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,
    required StorageRepository storageRepository,
    required SupabaseClient supabaseClient,
  }) : _communityRepository = communityRepository,
       _storageRepository = storageRepository,
       _ref = ref,
       _supabaseClient = supabaseClient,
       super(false);

  void createCommunity(String name, BuildContext context) async {
    // Get the authenticated user's ID from Supabase
    final currentUser = _supabaseClient.auth.currentUser;
    final uid = currentUser?.id;
    
    // Check if user is authenticated
    if (uid == null || uid.isEmpty) {
      showSnackBar(context, "You must be logged in to create a community");
      return;
    }

    state = true;
    Community community = Community(
      name: name,
      title: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );

    await _communityRepository.createCommunity(community).then((res) {
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, "Community created successfully!");
        Routemaster.of(context).pop();
      });
    });
  }

  // Get user communities from Supabase
  Stream<List<Community>> getUserCommunities() {
    final uid = _supabaseClient.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      return Stream.value([]);
    }
    return _communityRepository.getUserCommunities(uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity({
    required File? bannerFile,
    required File? profileFile,
    required BuildContext context,
    required Community community,
  }) async {
    state = true;

    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
        bucket: 'community-images',
        path: 'profiles',
        id: community.name,
        file: profileFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) {
          // Add cache-bust parameter properly to the URL
          final separator = r.contains('?') ? '&' : '?';
          final newUrl = '$r${separator}v=${DateTime.now().millisecondsSinceEpoch}';
          community = community.copyWith(avatar: newUrl);
        },
      );
    }

    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
        bucket: 'community-images',
        path: 'banners',
        id: community.name,
        file: bannerFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) {
          // Add cache-bust parameter properly to the URL
          final separator = r.contains('?') ? '&' : '?';
          final newUrl = '$r${separator}v=${DateTime.now().millisecondsSinceEpoch}';
          community = community.copyWith(banner: newUrl);
        },
      );
    }

    final res = await _communityRepository.editCommunity(community);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        // Clear image cache to force reload
        imageCache.clear();
        imageCache.clearLiveImages();
        
        // Invalidate the cache to force a refresh of the community data
        _ref.invalidate(getCommunityByNameProvider(community.name));
        showSnackBar(context, "Community updated successfully!");
        Routemaster.of(context).pop();
      },
    );
  }

  void joinCommunity(String communityName, BuildContext context) async {
    // Get the authenticated user's ID from Supabase
    final currentUser = _supabaseClient.auth.currentUser;
    final uid = currentUser?.id;
    
    // Check if user is authenticated
    if (uid == null || uid.isEmpty) {
      showSnackBar(context, "You must be logged in to join a community");
      return;
    }

    state = true;
    await _communityRepository.joinCommunity(communityName, uid).then((res) {
      state = false;
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) {
          // Invalidate both providers to refresh the UI
          _ref.invalidate(getCommunityByNameProvider(communityName));
          _ref.invalidate(userCommunitiesProvider);
          showSnackBar(context, "Successfully joined community!");
        },
      );
    });
  }

  Future<List<Community>> searchCommunities(String query){
    return _communityRepository.searchCommunities(query);
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:routemaster/routemaster.dart';
import 'package:threadly/core/constants/constants.dart';
import 'package:threadly/core/utils.dart';
import 'package:threadly/features/auth/presentation/pages/providers/auth_controller.dart';
import 'package:threadly/features/communities/data/models/community_model.dart';
import 'package:threadly/features/communities/domain/repository/community_repository.dart';

final userCommunitiesProvider = StreamProvider((ref){
  final communityController = ref.watch(communityControllerProvider.notifier);

  return communityController.getUserCommunities();
});

final communityControllerProvider = StateNotifierProvider<CommunityController, bool>((ref){
  final communityRepository = ref.watch(communityRepositoryProvider);
  return CommunityController(communityRepository: communityRepository, ref: ref);
});

class CommunityController extends StateNotifier<bool>{
  final CommunityRepository _communityRepository;
  final Ref _ref;
  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,

  }) : _communityRepository = communityRepository,
       _ref = ref, super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    Community community = Community(
      id: name,
      name: name,
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
// we cant use ref in repository
  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)?.uid ?? '';
    return _communityRepository.getUserCommunities(uid);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:threadly/core/common/loader.dart';
import 'package:threadly/features/communities/presentation/providers/community_controller.dart';

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;
  SearchCommunityDelegate(this.ref);
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchCommunityProvider(query)).when(
      data: (communities) {
        return ListView.builder(
          itemCount: communities.length,
          itemBuilder: (context, index) {
            final community = communities[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(community.getAvatarUrl()),
              ),
              title: Text('t/${community.name}'),
              onTap: () {
                navigateToCommunity(context, community.name);
              },
            );
          },
        );
      },
      loading: () => const Loader(),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),);
  }

  void navigateToCommunity(BuildContext context, String communityName) {
    Routemaster.of(context).push('/t/$communityName');
  }
}
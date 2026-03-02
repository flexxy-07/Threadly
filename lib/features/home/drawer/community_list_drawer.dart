import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:threadly/core/common/error_text.dart';
import 'package:threadly/core/common/loader.dart';
import 'package:threadly/features/communities/presentation/providers/community_controller.dart';


class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});


  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(child: Column(
        children: [
          ListTile(
            title: const Text('Create a community'),
            leading: const Icon(Icons.add),
            onTap: () => navigateToCreateCommunity(context)  ,
          ),
            ref.watch(userCommunitiesProvider).when(data: (communities) => Expanded(
              child: ListView.builder(
                itemCount: communities.length,
                itemBuilder: (BuildContext context, int index) => ListTile(title: Text('t/${communities[index].name}'),onTap: (){}, leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  communities[index].avatar,
                ),
                
              ),)),
            ), error: (error,stackTrace) => ErrorText(error: error.toString()), loading: () => const Loader())

        ],
      ))
    );
  }
}

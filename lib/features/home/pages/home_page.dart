import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threadly/core/common/loader.dart';
import 'package:threadly/features/auth/presentation/pages/providers/auth_controller.dart';
import 'package:threadly/features/home/delegates/search_community_delegate.dart';
import 'package:threadly/features/home/drawer/community_list_drawer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return const Loader();
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(onPressed: () => displayDrawer(context), icon: Icon(Icons.menu));
          }
        ),
        title: Text('Home'),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {
            showSearch(context: context, delegate: SearchCommunityDelegate(ref));
          }, icon: Icon(Icons.search)),
          IconButton(
            icon: CircleAvatar(backgroundImage: NetworkImage(user.profilePic)),
            onPressed: () {},
          ),
        ],
      ),
      drawer: CommunityListDrawer(),
    );
  }
}

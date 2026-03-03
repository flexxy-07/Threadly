import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:threadly/features/auth/presentation/pages/providers/auth_controller.dart';
import 'package:threadly/features/communities/presentation/providers/community_controller.dart';

class CommunityPage extends ConsumerWidget {
  final String name;

  const CommunityPage({super.key, required this.name});

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$name');
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authControllerProvider);
    return Scaffold(
      body: ref
          .watch(getCommunityByNameProvider(name))
          .when(
            data: (community) {
              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 150,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              community.getBannerUrl(),
                              key: ValueKey(community.getBannerUrl()),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CircleAvatar(
                              key: ValueKey(community.getAvatarUrl()),
                              backgroundImage: NetworkImage(community.getAvatarUrl()),
                              radius: 35,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                't/${community.name}',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              userAsync.when(
                                data: (user) {
                                  if (community.mods.contains(user?.uid ?? '')) {
                                    // User is a mod - show Mod tools
                                    return ElevatedButton(
                                      onPressed: () {
                                        navigateToModTools(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Mod tools'),
                                    );
                                  } else if (community.members.contains(user?.uid ?? '')) {
                                    // User is a regular member - show Joined
                                    return ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Joined'),
                                    );
                                  } else {
                                    // User is not a member - show Join
                                    return ElevatedButton(
                                      onPressed: () {
                                        ref.read(communityControllerProvider.notifier).joinCommunity(name, context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Join'),
                                    );
                                  }
                                },
                                loading: () => const SizedBox(
                                  width: 100,
                                  height: 36,
                                  child: CircularProgressIndicator(),
                                ),
                                error: (error, stack) => ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Join'),
                                ),
                              ),
                            ],
                          ),


                        ]),
                      ),
                    ),
                  ];
                },
                body: const Center(child: Text('Community body')),
              );
            },
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const CircularProgressIndicator(),
          ),
    );
  }
}

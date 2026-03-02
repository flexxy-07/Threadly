import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threadly/core/common/loader.dart';
import 'package:threadly/features/communities/presentation/providers/community_controller.dart';

class CreateCommunityPage extends ConsumerStatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  ConsumerState<CreateCommunityPage> createState() =>
      _CreateCommunityPageState();
}

class _CreateCommunityPageState extends ConsumerState<CreateCommunityPage> {
  final communityNameController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }
  
  void createCommunity() {
    ref.read(communityControllerProvider.notifier).createCommunity(
      communityNameController.text.trim(),
      context,
    );
  }
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a community'),
        centerTitle: true,
      ),
      body: isLoading ? const Loader() :  Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Align(alignment: Alignment.topLeft, child: Text('Community name')),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 't/Community_name',
                filled: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(18),
              ),
              maxLength: 21,
              controller: communityNameController,
            ),

            const SizedBox(height: 20),
            ElevatedButton(onPressed: createCommunity,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white
            ), child: const Text('Create Community'),
            ) 
          ],
        ),
      ),
    );
  }
}

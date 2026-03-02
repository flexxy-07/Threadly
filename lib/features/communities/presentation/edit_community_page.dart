import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threadly/core/common/error_text.dart';
import 'package:threadly/core/common/loader.dart';
import 'package:threadly/core/constants/constants.dart';
import 'package:threadly/core/utils.dart';
import 'package:threadly/features/communities/data/models/community_model.dart';
import 'package:threadly/features/communities/presentation/providers/community_controller.dart';

class EditCommunityPage extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityPage({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityPageState();
}

class _EditCommunityPageState extends ConsumerState<EditCommunityPage> {

  File? bannerFile;
  File? profileFile;

  void selectBannerImage() async {
    final res = await pickImage();
    if(res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();
    if(res != null) {
      setState(() {
        profileFile = File(res.files.first.path!);
      });
    }
  }

  void save(Community community) async {
    ref.read(communityControllerProvider.notifier).editCommunity(
      profileFile: profileFile,
      bannerFile: bannerFile,
      context: context,
      community: community,

    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider); 
    return ref
        .watch(getCommunityByNameProvider(widget.name))
        .when(
          data: (community) => Scaffold(
            appBar: AppBar(
              title: const Text(
                'Edit Community',
                style: TextStyle(fontSize: 20),
              ),
              actions: [
                TextButton(
                  onPressed: () => save(community),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
            body: isLoading ? const Loader() : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Banner Image Section
                  GestureDetector(
                    onTap: selectBannerImage,
                    child: DottedBorder(
                      options: RectDottedBorderOptions(
                        strokeWidth: 2,
                        dashPattern: [10, 4],
                        color: Colors.white
                      ),
                      child: bannerFile != null 
                        ? SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: Image.file(
                              bannerFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : community.banner.isEmpty || community.banner == Constants.bannerDefault ? Container(
                            height: 150,
                            width: double.infinity,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined, size: 40),
                                SizedBox(height: 8),
                                Text('Tap to update banner'),
                              ],
                            ),
                          ) 
                        : SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: Image.network(
                              community.banner,
                              fit: BoxFit.cover,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Profile Image Section
                  const Text(
                    'Community Avatar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: selectProfileImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: profileFile != null 
                            ? FileImage(profileFile!)
                            : NetworkImage(community.avatar) as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blueAccent,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}

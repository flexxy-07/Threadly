import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:threadly/core/common/failure.dart';
import 'package:threadly/core/constants/firebase_constants.dart';
import 'package:threadly/core/type_defs.dart';
import 'package:threadly/features/auth/presentation/pages/providers/auth_controller.dart';
import 'package:threadly/features/communities/data/models/community_model.dart';

final communityRepositoryProvider = Provider((ref){
  return CommunityRepository(firestore : ref.watch(firebaseFirestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  FutureVoid createCommunity(Community community) async {
    try {

      var communityDoc = await _communities.doc(community.name).get();
      if(communityDoc.exists){
        throw 'Community with the same name already exist!';
      }

      return right(_communities.doc(community.name).set(community.toMap()));
    }on FirebaseException catch (e) {
      return left(Failure(e.message!));
    }catch (e){
      return left(Failure(e.toString()));  
    }
  }

  Stream<List<Community>> getUserCommunities(String uid){
    return _communities.where('members', arrayContains: uid).snapshots().map((event) => event.docs.map((e) => Community.fromMap(e.data() as Map<String, dynamic>)).toList());
  }  

  CollectionReference get _communities => _firestore.collection(FirebaseConstants.communitiesCollection);

  
}
import 'package:self_host_group_chat_app/features/data/models/group_entity.dart';
import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class JoinGroupRepository {
  final FirebaseServices repository;

  JoinGroupRepository({required this.repository});

  Future<void> call(GroupEntity groupEntity) async {
    return await repository.joinGroup(groupEntity);
  }
}

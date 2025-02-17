import 'package:self_host_group_chat_app/features/data/models/group_entity.dart';
import 'package:self_host_group_chat_app/features/data/models/user_entity.dart';
import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class UpdateGroupUseCase {
  final FirebaseServices repository;

  UpdateGroupUseCase({required this.repository});
  Future<void> call(GroupEntity groupEntity) {
    return repository.updateGroup(groupEntity);
  }
}

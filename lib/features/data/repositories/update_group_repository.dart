import 'package:group_chat/features/data/models/group_entity.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';

class UpdateGroupRepository {
  final FirebaseServices repository;

  UpdateGroupRepository({required this.repository});
  Future<void> call(GroupEntity groupEntity) {
    return repository.updateGroup(groupEntity);
  }
}

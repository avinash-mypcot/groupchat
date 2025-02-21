import 'package:group_chat/features/data/models/group_entity.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';

class GetCreateGroupRepository {
  final FirebaseServices repository;

  GetCreateGroupRepository({required this.repository});

  Future<void> call(GroupEntity groupEntity) async {
    return await repository.getCreateGroup(groupEntity);
  }
}

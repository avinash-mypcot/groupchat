import 'package:group_chat/features/data/models/my_chat_entity.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';

class CreateNewGroupRepository {
  final FirebaseServices repository;

  CreateNewGroupRepository({required this.repository});

  Future<void> call(
      MyChatEntity myChatEntity, List<String> selectUserList) async {
    return repository.createNewGroup(myChatEntity, selectUserList);
  }
}

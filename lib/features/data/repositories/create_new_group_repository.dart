import 'package:self_host_group_chat_app/features/data/models/my_chat_entity.dart';
import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class CreateNewGroupUseCase {
  final FirebaseServices repository;

  CreateNewGroupUseCase({required this.repository});

  Future<void> call(
      MyChatEntity myChatEntity, List<String> selectUserList) async {
    return repository.createNewGroup(myChatEntity, selectUserList);
  }
}

import 'package:group_chat/features/data/models/my_chat_entity.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';

class GetCreateNewGroupChatRoomRepository {
  final FirebaseServices repository;

  GetCreateNewGroupChatRoomRepository({required this.repository});

  Future<void> call(MyChatEntity myChatEntity, List<String> selectUserList) {
    return repository.getCreateNewGroupChatRoom(myChatEntity, selectUserList);
  }
}

import 'package:group_chat/features/data/models/my_chat_entity.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';

class AddToMyChatRepository {
  final FirebaseServices repository;

  AddToMyChatRepository({required this.repository});

  Future<void> call(MyChatEntity myChatEntity) async {
    return await repository.addToMyChat(myChatEntity);
  }
}

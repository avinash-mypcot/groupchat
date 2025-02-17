import 'package:self_host_group_chat_app/features/data/models/my_chat_entity.dart';
import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class AddToMyChatUseCase {
  final FirebaseServices repository;

  AddToMyChatUseCase({required this.repository});

  Future<void> call(MyChatEntity myChatEntity) async {
    return await repository.addToMyChat(myChatEntity);
  }
}

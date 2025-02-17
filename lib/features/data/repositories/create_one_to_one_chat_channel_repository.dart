import 'package:self_host_group_chat_app/features/data/models/engage_user_entity.dart';
import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class CreateOneToOneChatChannelUseCase {
  final FirebaseServices repository;

  CreateOneToOneChatChannelUseCase({required this.repository});

  Future<String> call(EngageUserEntity engageUserEntity) async {
    return repository.createOneToOneChatChannel(engageUserEntity);
  }
}

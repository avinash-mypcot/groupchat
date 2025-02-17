import 'package:self_host_group_chat_app/features/data/models/engage_user_entity.dart';
import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class GetChannelIdUseCase {
  final FirebaseServices repository;

  GetChannelIdUseCase({required this.repository});

  Future<String> call(EngageUserEntity engageUserEntity) async {
    return repository.getChannelId(engageUserEntity);
  }
}

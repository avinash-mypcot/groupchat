import 'package:group_chat/features/data/models/engage_user_entity.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';

class GetChannelIdRepository {
  final FirebaseServices repository;

  GetChannelIdRepository({required this.repository});

  Future<String> call(EngageUserEntity engageUserEntity) async {
    return repository.getChannelId(engageUserEntity);
  }
}

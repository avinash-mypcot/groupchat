import 'package:group_chat/features/data/models/my_chat_entity.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';

class GetMyChatRepository {
  final FirebaseServices repository;

  GetMyChatRepository({required this.repository});

  Stream<List<MyChatEntity>> call(String uid) {
    return repository.getMyChat(uid);
  }
}

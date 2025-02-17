import 'package:self_host_group_chat_app/features/data/models/text_messsage_entity.dart';
import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class GetMessageUseCase {
  final FirebaseServices repository;

  GetMessageUseCase({required this.repository});

  Stream<List<TextMessageEntity>> call(String channelId) {
    return repository.getMessages(channelId);
  }
}

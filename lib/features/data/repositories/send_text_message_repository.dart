import 'package:self_host_group_chat_app/features/data/models/text_messsage_entity.dart';
import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class SendTextMessageRepository {
  final FirebaseServices repository;

  SendTextMessageRepository({required this.repository});

  Future<void> call(
      TextMessageEntity textMessageEntity, String channelId) async {
    return await repository.sendTextMessage(textMessageEntity, channelId);
  }
}

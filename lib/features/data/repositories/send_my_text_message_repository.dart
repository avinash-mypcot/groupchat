import 'package:group_chat/features/data/models/text_messsage_entity.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';

import '../../../core/services/hive/hive_model.dart';

class SendMyTextMessage {
  final FirebaseServices repository;

  SendMyTextMessage({required this.repository});

  Future<void> call(
      TextMessageModel textMessageEntity, String channelId) async {
    return await repository.sendTextMessage(textMessageEntity, channelId);
  }
}

import 'package:group_chat/features/data/services/firebase_services.dart';
import '../../../core/services/hive/hive_model.dart';

class SendTextMessageRepository {
  final FirebaseServices repository;

  SendTextMessageRepository({required this.repository});

  Future<void> call(
      TextMessageModel textMessageEntity, String channelId) async {
    return await repository.sendTextMessage(textMessageEntity, channelId);
  }
}

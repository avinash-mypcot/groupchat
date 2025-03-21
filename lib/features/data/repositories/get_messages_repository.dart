import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';
import '../../../core/services/hive/hive_model.dart';

class GetMessageRepository {
  final FirebaseServices repository;

  GetMessageRepository({required this.repository});

  Stream<List<TextMessageModel>> call(String channelId) {
    return repository.getMessages(channelId);
  }
}

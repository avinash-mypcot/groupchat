import 'package:group_chat/features/data/models/user_entity.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';

class GetCreateCurrentUserRepository {
  final FirebaseServices repository;

  GetCreateCurrentUserRepository({required this.repository});

  Future<void> call(UserEntity user) async {
    return repository.getCreateCurrentUser(user);
  }
}

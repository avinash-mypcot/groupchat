import 'package:group_chat/features/data/models/user_entity.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';

class GetAllUsersRepository {
  final FirebaseServices repository;

  GetAllUsersRepository({required this.repository});

  Stream<List<UserEntity>> call() {
    return repository.getAllUsers();
  }
}

import 'package:group_chat/features/data/models/user_entity.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';

class SignUpRepository {
  final FirebaseServices repository;

  SignUpRepository({required this.repository});

  Future<void> call(UserEntity user) {
    return repository.signUp(user);
  }
}

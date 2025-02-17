import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class SignOutUseCase {
  final FirebaseServices repository;

  SignOutUseCase({required this.repository});

  Future<void> call() async {
    return repository.signOut();
  }
}

import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class GoogleSignInUseCase {
  final FirebaseServices repository;

  GoogleSignInUseCase({required this.repository});

  Future<void> call() {
    return repository.googleAuth();
  }
}

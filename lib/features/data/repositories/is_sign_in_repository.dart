import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class IsSignInUseCase {
  final FirebaseServices repository;

  IsSignInUseCase({required this.repository});

  Future<bool> call() async {
    return repository.isSignIn();
  }
}

import 'package:group_chat/features/data/services/firebase_services.dart';

class GoogleSignInRepository {
  final FirebaseServices repository;

  GoogleSignInRepository({required this.repository});

  Future<void> call() {
    return repository.googleAuth();
  }
}

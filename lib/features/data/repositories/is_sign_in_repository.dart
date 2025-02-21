import 'package:group_chat/features/data/services/firebase_services.dart';

class IsSignInRepository {
  final FirebaseServices repository;

  IsSignInRepository({required this.repository});

  Future<bool> call() async {
    return repository.isSignIn();
  }
}

import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class ForgotPasswordRepository {
  final FirebaseServices repository;

  ForgotPasswordRepository({required this.repository});

  Future<void> call(String email) {
    return repository.forgotPassword(email);
  }
}

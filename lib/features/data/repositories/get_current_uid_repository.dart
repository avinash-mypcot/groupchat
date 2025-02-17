import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class GetCurrentUIDUseCase {
  final FirebaseServices repository;

  GetCurrentUIDUseCase({required this.repository});
  Future<String> call() async {
    return await repository.getCurrentUId();
  }
}

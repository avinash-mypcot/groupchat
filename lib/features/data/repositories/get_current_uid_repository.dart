import 'package:group_chat/features/data/services/firebase_services.dart';

class GetCurrentUIDRepository {
  final FirebaseServices repository;

  GetCurrentUIDRepository({required this.repository});
  Future<String> call() async {
    return await repository.getCurrentUId();
  }
}

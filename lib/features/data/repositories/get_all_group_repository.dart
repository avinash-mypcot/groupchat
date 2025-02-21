import 'package:group_chat/features/data/models/group_entity.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';

class GetAllGroupsRepository {
  final FirebaseServices repository;

  GetAllGroupsRepository({required this.repository});

  Stream<List<GroupEntity>> call() {
    return repository.getGroups();
  }
}

import 'package:self_host_group_chat_app/features/data/models/group_entity.dart';
import 'package:self_host_group_chat_app/features/data/models/user_entity.dart';
import 'package:self_host_group_chat_app/features/data/services/firebase_services.dart';

class GetAllGroupsUseCase {
  final FirebaseServices repository;

  GetAllGroupsUseCase({required this.repository});

  Stream<List<GroupEntity>> call() {
    return repository.getGroups();
  }
}

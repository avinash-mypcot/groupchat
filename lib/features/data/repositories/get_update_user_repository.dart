import 'dart:developer';

import 'package:group_chat/features/data/models/user_entity.dart';
import 'package:group_chat/features/data/services/firebase_services.dart';

class GetUpdateUserRepository {
  final FirebaseServices repository;

  GetUpdateUserRepository({required this.repository});
  Future<void> call(String user) {
    log("IN REPOPO");
    return repository.getUpdateUser(user);
  }
}

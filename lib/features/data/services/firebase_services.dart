import 'package:group_chat/features/data/models/engage_user_entity.dart';
import 'package:group_chat/features/data/models/group_entity.dart';
import 'package:group_chat/features/data/models/my_chat_entity.dart';
import 'package:group_chat/features/data/models/user_entity.dart';
import '../../../core/services/hive/hive_model.dart';
import '../api/firebase_remote_data_source.dart';

class FirebaseServices {
  final FirebaseRemoteDataSource remoteDataSource;

  FirebaseServices({required this.remoteDataSource});

  Future<void> getCreateCurrentUser(UserEntity user) async =>
      await remoteDataSource.getCreateCurrentUser(user);

  Future<String> getCurrentUId() async =>
      await remoteDataSource.getCurrentUId();

  Future<bool> isSignIn() async => await remoteDataSource.isSignIn();

  Future<void> signInWithPhoneNumber(String pinCode) async =>
      await remoteDataSource.signInWithPhoneNumber(pinCode);

  Future<void> signOut() async => await remoteDataSource.signOut();

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    await remoteDataSource.verifyPhoneNumber(phoneNumber);
  }

  Stream<List<UserEntity>> getAllUsers() => remoteDataSource.getAllUsers();

  Future<String> createOneToOneChatChannel(
          EngageUserEntity engageUserEntity) async =>
      remoteDataSource.createOneToOneChatChannel(engageUserEntity);

  Future<void> sendTextMessage(
      TextMessageModel textMessageEntity, String channelId) async {
    return await remoteDataSource.sendTextMessage(textMessageEntity, channelId);
  }

  Stream<List<TextMessageModel>> getMessages(String channelId) {
    return remoteDataSource.getMessages(channelId);
  }

  Future<String> getChannelId(EngageUserEntity engageUserEntity) async {
    return remoteDataSource.getChannelId(engageUserEntity);
  }

  Future<void> addToMyChat(MyChatEntity myChatEntity) async {
    return await remoteDataSource.addToMyChat(myChatEntity);
  }

  Stream<List<MyChatEntity>> getMyChat(String uid) {
    return remoteDataSource.getMyChat(uid);
  }

  Future<void> createNewGroup(
      MyChatEntity myChatEntity, List<String> selectUserList) {
    return remoteDataSource.createNewGroup(myChatEntity, selectUserList);
  }

  Future<void> getCreateNewGroupChatRoom(
      MyChatEntity myChatEntity, List<String> selectUserList) {
    return remoteDataSource.createNewGroup(myChatEntity, selectUserList);
  }

  Future<void> googleAuth() async => remoteDataSource.googleAuth();

  Future<void> forgotPassword(String email) async =>
      remoteDataSource.forgotPassword(email);

  Future<void> signIn(UserEntity user) async => remoteDataSource.signIn(user);

  Future<void> signUp(UserEntity user) async => remoteDataSource.signUp(user);

  Future<void> getUpdateUser(UserEntity user) async =>
      remoteDataSource.getUpdateUser(user);

  Future<void> getCreateGroup(GroupEntity groupEntity) async =>
      remoteDataSource.getCreateGroup(groupEntity);

  Stream<List<GroupEntity>> getGroups() => remoteDataSource.getGroups();

  Future<void> joinGroup(GroupEntity groupEntity) async =>
      remoteDataSource.joinGroup(groupEntity);

  Future<void> updateGroup(GroupEntity groupEntity) async =>
      remoteDataSource.updateGroup(groupEntity);
}

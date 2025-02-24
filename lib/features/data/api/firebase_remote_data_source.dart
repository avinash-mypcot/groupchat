import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:group_chat/features/data/models/engage_user_entity.dart';
import 'package:group_chat/features/data/models/group_entity.dart';
import 'package:group_chat/features/data/models/my_chat_entity.dart';
import 'package:group_chat/features/data/models/user_entity.dart';
import 'package:group_chat/injection_container.dart';
import '../../../core/services/hive/hive_model.dart';
import '../../../core/services/network/bloc/network_bloc.dart';
import '../models/group_model.dart';
import '../models/my_chat_model.dart';
import '../models/user_model.dart';

class FirebaseRemoteDataSource {
  final FirebaseFirestore fireStore;
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;

  String _verificationId = "";

  FirebaseRemoteDataSource(this.fireStore, this.auth, this.googleSignIn);
 Future<String?> getFcmTokenByUid(String uid) async {
  try {
    final userDoc = await fireStore.collection("users").doc(uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      return userDoc.data()?["fcmToken"];
    } else {
      print("User not found");
      return null;
    }
  } catch (e) {
    print("Error fetching FCM token: $e");
    return null;
  }
}


  Future<void> getCreateCurrentUser(UserEntity user) async {
    final userCollection = fireStore.collection("users");
    final uid = await getCurrentUId();
    userCollection.doc(uid).get().then((userDoc) {
      final newUser = UserModel(
        name: user.name,
        uid: uid,
        phoneNumber: user.phoneNumber,
        email: user.email,
        profileUrl: user.profileUrl,
        isOnline: user.isOnline,
        status: user.status,
        dob: user.dob,
        gender: user.gender,
        fcmToken: user.fcmToken
        
      ).toDocument();
      if (!userDoc.exists) {
        userCollection.doc(uid).set(newUser);
        return;
      } else {
        userCollection.doc(uid).update(newUser);
        print("user already exist");
        return;
      }
    }).catchError((error) {
      print(error);
    });
  }

  Future<String> getCurrentUId() async => auth.currentUser!.uid;

  Future<bool> isSignIn() async => auth.currentUser?.uid != null;

  Future<void> signInWithPhoneNumber(String pinCode) async {
    final AuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: pinCode);
    await auth.signInWithCredential(authCredential);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    final PhoneVerificationCompleted phoneVerificationCompleted =
        (AuthCredential authCredential) {
      print("phone is verified : token ${authCredential.token}");
    };
    final PhoneVerificationFailed phoneVerificationFailed =
        (FirebaseAuthException authCredential) {
      print("phone failed ${authCredential.message},${authCredential.code}");
    };
    final PhoneCodeAutoRetrievalTimeout phoneCodeAutoRetrievalTimeout =
        (String verificationId) {
      this._verificationId = verificationId;
      print("time out $verificationId");
    };
    final PhoneCodeSent phoneCodeSent =
        (String verificationID, [int? forceResendingToken]) {
      this._verificationId = verificationID;
      print("sendPhoneCode $verificationID");
    };

    auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: phoneVerificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout);
  }

  Future<String> getChannelId(EngageUserEntity engageUserEntity) {
    final userCollectionRef = fireStore.collection("users");
    print(
        "uid ${engageUserEntity.uid} - otherUid ${engageUserEntity.otherUid}");
    return userCollectionRef
        .doc(engageUserEntity.uid)
        .collection('chatChannel')
        .doc(engageUserEntity.otherUid)
        .get()
        .then((chatChannelId) {
      if (chatChannelId.exists) {
        return chatChannelId.get('channelId');
      } else
        return Future.value(null);
    });
  }

  Stream<List<UserEntity>> getAllUsers() {
    final userCollection = fireStore.collection("users");
    return userCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList());
  }

  Future<String> createOneToOneChatChannel(
      EngageUserEntity engageUserEntity) async {
    //User Collection Reference
    final userCollectionRef = fireStore.collection("users");

    final oneToOneChatChannelRef = fireStore.collection("OneToOneChatChannel");
    //ChatChannelMap
    userCollectionRef
        .doc(engageUserEntity.uid)
        .collection("chatChannel")
        .doc(engageUserEntity.otherUid)
        .get()
        .then((chatChannelDoc) {
      //Chat Channel exists
      if (chatChannelDoc.exists) {
        return chatChannelDoc.get('channelId');
      }

      final _chatChannelId = oneToOneChatChannelRef.doc().id;

      var channel = {'channelId': _chatChannelId};
      var channel1 = {
        'channelId': _chatChannelId,
      };

      oneToOneChatChannelRef.doc(_chatChannelId).set(channel);

      //currentUser
      userCollectionRef
          .doc(engageUserEntity.uid)
          .collection('chatChannel')
          .doc(engageUserEntity.otherUid)
          .set(channel);

      //otherUser
      userCollectionRef
          .doc(engageUserEntity.otherUid)
          .collection('chatChannel')
          .doc(engageUserEntity.uid)
          .set(channel);

      return _chatChannelId;
    });
    return Future.value("");
  }

  Future<void> sendTextMessage(
      TextMessageModel textMessageEntity, String channelId) async {
    final messagesRef = fireStore
        .collection("groupChatChannel")
        .doc(channelId)
        .collection("messages");

    final messageId = messagesRef.doc().id;

    final newMessage = TextMessageModel(
      expiredAt: textMessageEntity.expiredAt,
      content: textMessageEntity.content,
      messageId: messageId,
      receiverName: textMessageEntity.receiverName,
      recipientId: textMessageEntity.recipientId,
      senderId: textMessageEntity.senderId,
      senderName: textMessageEntity.senderName,
      time: textMessageEntity.time,
      type: textMessageEntity.type,
    );
    final currentState = serviceLocator<NetworkBloc>().state;
    // Save to Firebase if connected
    // if (await currentState is NetworkSuccess) {
    log("STORING LOCAL DATA");
    try {
      await messagesRef.doc(messageId).set(newMessage.toDocument());
    } catch (e) {
      log("STORING LOCAL DATA11$e");
    }

    // } else {
    // Save to Hive for offline storage
    // var box = await Hive.box<TextMessageModel>('messages');
    // box.put(messageId, newMessage);
    // }
  }

  Stream<List<TextMessageModel>> getMessages(String channelId) async* {
    final oneToOneChatChannelRef = fireStore.collection("groupChatChannel");
    final messagesRef =
        oneToOneChatChannelRef.doc(channelId).collection("messages");
    final currentState = serviceLocator<NetworkBloc>().state;
    // Save to Firebase if connected
    log('GET MESSAGE1212$currentState');
    // if (await currentState is NetworkSuccess) {
    yield* messagesRef.orderBy('time').snapshots().map((querySnap) {
      final messages = querySnap.docs
          .map((queryDoc) => TextMessageModel.fromSnapshot(queryDoc))
          .where((message) => message.expiredAt!.isAfter(DateTime.now()))
          .toList();

      // Save to Hive
      // _saveMessagesToHive(channelId, messages);

      return messages;
    });
    // } else {
    //   log('GET Offline MESSAGE ');
    //   // If offline, get messages from Hive
    //   var box = await Hive.box<TextMessageModel1>('messages');
    //   log("${box.values.length}");
    //   yield [];
    // }
  }

  Future<void> addToMyChat(MyChatEntity myChatEntity) async {
    final myChatRef = fireStore
        .collection("users")
        .doc(myChatEntity.senderUID)
        .collection("myChat");
    final otherChatRef = fireStore
        .collection("users")
        .doc(myChatEntity.recipientUID)
        .collection("myChat");

    final myNewChatCurrentUser = MyChatModel(
      channelId: myChatEntity.channelId,
      senderName: myChatEntity.senderName,
      time: myChatEntity.time,
      recipientName: myChatEntity.recipientName,
      recipientPhoneNumber: myChatEntity.recipientPhoneNumber,
      recipientUID: myChatEntity.recipientUID,
      senderPhoneNumber: myChatEntity.senderPhoneNumber,
      senderUID: myChatEntity.senderUID,
      profileUrl: myChatEntity.profileUrl,
      isArchived: myChatEntity.isArchived,
      isRead: myChatEntity.isRead,
      recentTextMessage: myChatEntity.recentTextMessage,
      subjectName: myChatEntity.subjectName,
    ).toDocument();
    final myNewChatOtherUser = MyChatModel(
      channelId: myChatEntity.channelId,
      senderName: myChatEntity.recipientName,
      time: myChatEntity.time,
      recipientName: myChatEntity.senderName,
      recipientPhoneNumber: myChatEntity.senderPhoneNumber,
      recipientUID: myChatEntity.senderUID,
      senderPhoneNumber: myChatEntity.recipientPhoneNumber,
      senderUID: myChatEntity.recipientUID,
      profileUrl: myChatEntity.profileUrl,
      isArchived: myChatEntity.isArchived,
      isRead: myChatEntity.isRead,
      recentTextMessage: myChatEntity.recentTextMessage,
      subjectName: myChatEntity.subjectName,
    ).toDocument();
    myChatRef.doc(myChatEntity.recipientUID).get().then((myChatDoc) {
      if (!myChatDoc.exists) {
        myChatRef.doc(myChatEntity.recipientUID).set(myNewChatCurrentUser);
        otherChatRef.doc(myChatEntity.senderUID).set(myNewChatOtherUser);
        return;
      } else {
        print("update");
        myChatRef.doc(myChatEntity.recipientUID).update(myNewChatCurrentUser);
        otherChatRef.doc(myChatEntity.senderUID).set(myNewChatOtherUser);

        return;
      }
    });
  }

  Stream<List<MyChatEntity>> getMyChat(String uid) {
    final myChatRef =
        fireStore.collection("users").doc(uid).collection("myChat");

    return myChatRef.orderBy('time', descending: true).snapshots().map(
      (querySnapshot) {
        return querySnapshot.docs.map((queryDocumentSnapshot) {
          return MyChatModel.fromSnapshot(queryDocumentSnapshot);
        }).toList();
      },
    );
  }

  Future<void> createNewGroup(
      MyChatEntity myChatEntity, List<String> selectUserList) async {
    print("createNewGroup ${myChatEntity.channelId}");
    print(myChatEntity.senderUID);
    await _createGroup(myChatEntity, selectUserList);
    return;
  }

  _createGroup(MyChatEntity myChatEntity, List<String> selectUserList) async {
    final myNewChatCurrentUser = MyChatModel(
      channelId: myChatEntity.channelId,
      senderName: myChatEntity.senderName,
      time: myChatEntity.time,
      recipientName: myChatEntity.recipientName,
      recipientPhoneNumber: myChatEntity.recipientPhoneNumber,
      recipientUID: myChatEntity.recipientUID,
      senderPhoneNumber: myChatEntity.senderPhoneNumber,
      senderUID: myChatEntity.senderUID,
      profileUrl: myChatEntity.profileUrl,
      isArchived: myChatEntity.isArchived,
      isRead: myChatEntity.isRead,
      recentTextMessage: myChatEntity.recentTextMessage,
      subjectName: myChatEntity.subjectName,
    ).toDocument();
    print("sender Id ${myChatEntity.senderUID}");
    await fireStore
        .collection("users")
        .doc(myChatEntity.senderUID)
        .collection("myChat")
        .doc(myChatEntity.channelId)
        .set(myNewChatCurrentUser)
        .then((value) {
      print("data created");
    }).catchError((error) {
      print("dataError $error");
    });
  }

  Future<void> googleAuth() async {
    final usersCollection = fireStore.collection("users");

    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await account!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final information = (await auth.signInWithCredential(credential)).user;
      usersCollection.doc(auth.currentUser!.uid).get().then((user) async {
        if (!user.exists) {
          var uid = auth.currentUser!.uid;
          //TODO Initialize currentUser if not exist record
          var newUser = UserModel(
                  name: information!.displayName!,
                  email: information.email!,
                  phoneNumber: information.phoneNumber == null
                      ? ""
                      : information.phoneNumber!,
                  profileUrl:
                      information.photoURL == null ? "" : information.photoURL!,
                  isOnline: false,
                  status: "",
                  dob: "",
                  gender: "",
                  uid: information.uid)
              .toDocument();

          usersCollection.doc(uid).set(newUser);
        }
      }).whenComplete(() {
        print("New User Created Successfully");
      }).catchError((e) {
        print("getInitializeCreateCurrentUser ${e.toString()}");
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signIn(UserEntity user) async {
    await auth.signInWithEmailAndPassword(
        email: user.email, password: user.password);
  }

  Future<void> signUp(UserEntity user) async {
    await auth.createUserWithEmailAndPassword(
        email: user.email, password: user.password);
  }

  Future<void> getUpdateUser(UserEntity user) async {
    Map<String, dynamic> userInformation = Map();
    print(user.name);
    final userCollection = fireStore.collection("users");

    if (user.profileUrl != "") userInformation['profileUrl'] = user.profileUrl;
    if (user.status != "") userInformation['status'] = user.status;
    if (user.phoneNumber != "")
      userInformation["phoneNumber"] = user.phoneNumber;
    if (user.name != "") userInformation["name"] = user.name;

    userCollection.doc(user.uid).update(userInformation);
  }

  Future<void> getCreateGroup(GroupEntity groupEntity) async {
    if (groupEntity.limitUsers == null) {
      log("groupEntity.limitUsers is NULL!");
      return;
    }

    if (groupEntity.limitUsers!.isEmpty) {
      log("groupEntity.limitUsers is EMPTY!");
      return;
    }

    final List<dynamic> users = List.from(groupEntity.limitUsers!);
    log("DATA LENGTH1: ${users.length}"); // Should show correct length

    final groupCollection = fireStore.collection("groups");
    final groupId = groupCollection.doc().id;

    final groupDoc =
        await groupCollection.doc(groupId).get(); // Await Firestore fetch
    log("DATA LENGTH2: ${users.length}"); // Should still show correct length

    final newGroup = GroupModel(
      groupId: groupId,
      limitUsers: users,
      joinUsers: groupEntity.joinUsers,
      groupProfileImage: groupEntity.groupProfileImage,
      creationTime: groupEntity.creationTime,
      groupName: groupEntity.groupName,
      lastMessage: groupEntity.lastMessage,
    ).toDocument();

    log("DATA LENGTH3: ${users.length}"); // Should still show correct length

    if (!groupDoc.exists) {
      await groupCollection.doc(groupId).set(newGroup);
    }
  }

  Stream<List<GroupEntity>> getGroups() {
    final groupCollection = fireStore.collection("groups");
    return groupCollection
        .orderBy("creationTime", descending: true)
        .snapshots()
        .map((querySnapshot) =>
            querySnapshot.docs.map((e) => GroupModel.fromSnapshot(e)).toList());
  }

  Future<void> joinGroup(GroupEntity groupEntity) async {
    final groupChatChannelCollection = fireStore.collection("groupChatChannel");

    groupChatChannelCollection
        .doc(groupEntity.groupId)
        .get()
        .then((groupChannel) {
      Map<String, dynamic> groupMap = {"groupChannelId": groupEntity.groupId};
      if (!groupChannel.exists) {
        groupChatChannelCollection.doc(groupEntity.groupId).set(groupMap);
        return;
      }
      return;
    });
  }

  Future<void> updateGroup(GroupEntity groupEntity) async {
    Map<String, dynamic> groupInformation = Map();

    final userCollection = fireStore.collection("groups");

    if (groupEntity.groupProfileImage != "")
      groupInformation['groupProfileImage'] = groupEntity.groupProfileImage;
    if (groupEntity.groupName != "")
      groupInformation["groupName"] = groupEntity.groupName;
    if (groupEntity.lastMessage != "")
      groupInformation["lastMessage"] = groupEntity.lastMessage;
    if (groupEntity.creationTime != null)
      groupInformation["creationTime"] = groupEntity.creationTime;

    userCollection.doc(groupEntity.groupId).update(groupInformation);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_chat/features/data/models/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    String name = "username",
    String email = "",
    String phoneNumber = "",
    bool isOnline = false,
    String uid = "",
    String status = "",
    String profileUrl = "",
    String dob = "",
    String gender = "",
    String fcmToken =''
  }) : super(
          fcmToken:fcmToken,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          isOnline: isOnline,
          uid: uid,
          status: status,
          profileUrl: profileUrl,
          gender: gender,
          dob: dob,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      isOnline: json['isOnline'],
      uid: json['uid'],
      status: json['status'],
      profileUrl: json['profileUrl'],
      fcmToken: json['fcmToken']
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    return UserModel(
      name: snapshot.get('name'),
      email: snapshot.get('email'),
      phoneNumber: snapshot.get('phoneNumber'),
      isOnline: snapshot.get('isOnline'),
      uid: snapshot.get('uid'),
      status: snapshot.get('status'),
      profileUrl: snapshot.get('profileUrl'),
      dob: snapshot.get('dob'),
      gender: snapshot.get('gender'),
      fcmToken: snapshot.get('fcmToken')
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "isOnline": isOnline,
      "uid": uid,
      "status": status,
      "profileUrl": profileUrl,
      "dob": dob,
      "gender": gender,
      "fcmToken": fcmToken
    };
  }
}

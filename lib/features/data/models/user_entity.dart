import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {

  final String name;
  final String email;
  final String phoneNumber;
  final bool isOnline;
  final String uid;
  final String status;
  final String profileUrl;
  final String password;
  final String dob;
  final String gender;
  final String fcmToken;


  UserEntity({
    this.fcmToken='',
    this.name="",
    this.email="",
    this.phoneNumber="",
    this.isOnline = false,
    this.uid="",
    this.status = "Hello there i'm using this app",
    this.profileUrl="",
    this.password="",
    this.dob="",
    this.gender="",
  });

  @override
  // TODO: implement props
  List<Object> get props => [
    name,
    fcmToken,
    email,
    phoneNumber,
    isOnline,
    uid,
    status,
    profileUrl,
    password,
    dob,
    gender,
  ];
}

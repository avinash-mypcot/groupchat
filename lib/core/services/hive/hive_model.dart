import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hive/hive.dart';

// part 'hive_model.g.dart';

// @HiveType(typeId: 0)
class TextMessageModel {
  // @HiveField(0)
  String? messageId;

  // @HiveField(1)
  String? content;

  // @HiveField(2)
  String? senderId;

  // @HiveField(3)
  String? receiverName;

  // @HiveField(4)
  String? recipientId;

  // @HiveField(5)
  String? senderName;

  // @HiveField(6)
  DateTime? time; //

  // @HiveField(7)
  String? type;

  // @HiveField(8)
  DateTime? expiredAt;

  TextMessageModel({
    required this.messageId,
    required this.content,
    required this.senderId,
    required this.receiverName,
    required this.recipientId,
    required this.senderName,
    required this.time,
    required this.type,
    required this.expiredAt,
  });

  //  Convert from Firestore snapshot
  factory TextMessageModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return TextMessageModel(
      messageId: snap.id,
      content: data['content'],
      senderId: data['senderId'],
      receiverName: data['receiverName'],
      recipientId: data['recipientId'],
      senderName: data['senderName'],
      time: (data['time'] as Timestamp)
          .toDate(), //  Convert Timestamp to DateTime
      type: data['type'],
      expiredAt: (data['expiredAt'] as Timestamp)
          .toDate(), //  Convert Timestamp to DateTime
    );
  }

  //  Convert to Firestore document
  Map<String, dynamic> toDocument() {
    return {
      "messageId": messageId,
      "content": content,
      "senderId": senderId,
      "receiverName": receiverName,
      "recipientId": recipientId,
      "senderName": senderName,
      "time": time != null
          ? Timestamp.fromDate(time!)
          : null, //  Convert DateTime to Timestamp
      "type": type,
      "expiredAt": expiredAt != null
          ? Timestamp.fromDate(expiredAt!)
          : null, //  Convert DateTime to Timestamp
    };
  }
}

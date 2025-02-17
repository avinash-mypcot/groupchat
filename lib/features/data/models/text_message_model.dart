import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:self_host_group_chat_app/features/data/models/text_messsage_entity.dart';

class TextMessageModel extends TextMessageEntity {
  TextMessageModel({
    Timestamp? expiredAt,
    String? recipientId,
    String? senderId,
    String? senderName,
    String? type,
    Timestamp? time,
    String? content,
    String? receiverName,
    String? messageId,
  }) : super(
          expiredAt: expiredAt,
          recipientId: recipientId,
          senderId: senderId,
          senderName: senderName,
          type: type,
          time: time,
          content: content,
          receiverName: receiverName,
          messageId: messageId,
        );

  factory TextMessageModel.fromSnapshot(DocumentSnapshot snapshot) {
    return TextMessageModel(
      expiredAt: snapshot.get('expiredAt'),
      recipientId: snapshot.get('recipientId'),
      senderId: snapshot.get('senderId'),
      senderName: snapshot.get('senderName'),
      type: snapshot.get('type'),
      time: snapshot.get('time'),
      content: snapshot.get('content'),
      receiverName: snapshot.get('receiverName'),
      messageId: snapshot.get('messageId'),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      "expiredAt": expiredAt,
      "recipientId": recipientId,
      "senderId": senderId,
      "senderName": senderName,
      "type": type,
      "time": time,
      "content": content,
      "receiverName": receiverName,
      "messageId": messageId,
    };
  }
}

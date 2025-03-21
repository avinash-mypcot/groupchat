import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TextMessageEntity extends Equatable {
  final String? recipientId;
  final String? senderId;
  final String? senderName;
  final String? type;
  final Timestamp? time;
  final String? content;
  final String? receiverName;
  final String? messageId;
  final Timestamp? expiredAt;

  TextMessageEntity({
    this.expiredAt,
    this.recipientId,
    this.senderId,
    this.senderName,
    this.type,
    this.time,
    this.content,
    this.receiverName,
    this.messageId,
  });

  @override
  List<Object> get props => [
        expiredAt!,
        recipientId!,
        senderId!,
        senderName!,
        type!,
        time!,
        content!,
        receiverName!,
        messageId!,
      ];
}

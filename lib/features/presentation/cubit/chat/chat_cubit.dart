import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:group_chat/features/data/repositories/get_messages_repository.dart';
import 'package:group_chat/features/data/repositories/send_text_message_repository.dart';
import '../../../../core/services/hive/hive_model.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendTextMessageRepository sendTextMessageRepository;
  final GetMessageRepository getMessageRepository;
  ChatCubit(
      {required this.getMessageRepository,
      required this.sendTextMessageRepository})
      : super(ChatInitial());

  Future<void> getMessages({
    required String channelId,
    DocumentSnapshot? lastDoc,
    bool isLoadMore = false, // ✅ Add flag for pagination
  }) async {
    log("LOADING MSG MSG MSG");

    if (lastDoc == null && !isLoadMore) {
      emit(ChatLoading());
    }

    final streamResponse = getMessageRepository.call(channelId, lastDoc);

    streamResponse.listen((newMessages) {
      log("LOADING MSG MSG MSG ${newMessages.length}");

      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;

        if (newMessages.isNotEmpty) {
          emit(ChatLoaded(
            messages: [
              ...currentState.messages,
              ...newMessages
            ], // ✅ Append messages
          ));
        }
      } else {
        emit(ChatLoaded(
          messages: newMessages,
        ));
      }
    });
  }

  Future<void> sendTextMessage(
      {required TextMessageModel textMessageEntity,
      required String channelId}) async {
    try {
      log("SENT MSG");
      await sendTextMessageRepository.call(textMessageEntity, channelId);
    } on SocketException catch (_) {
      emit(ChatFailure());
    } catch (_) {
      log("SENT MSG EROOR $_");

      emit(ChatFailure());
    }
  }
}

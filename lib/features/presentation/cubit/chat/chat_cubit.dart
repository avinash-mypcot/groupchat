import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:self_host_group_chat_app/features/data/models/text_messsage_entity.dart';
import 'package:self_host_group_chat_app/features/data/repositories/get_messages_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/send_text_message_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendTextMessageRepository sendTextMessageRepository;
  final GetMessageRepository getMessageRepository;
  ChatCubit(
      {required this.getMessageRepository,
      required this.sendTextMessageRepository})
      : super(ChatInitial());

  Future<void> getMessages({required String channelId}) async {
    log("LOADING MSG MSG MSG");
    emit(ChatLoading());
    final streamResponse = getMessageRepository.call(channelId);
    streamResponse.listen((messages) {
      emit(ChatLoaded(messages: messages));
    });
  }

  Future<void> sendTextMessage(
      {required TextMessageEntity textMessageEntity,
      required String channelId}) async {
    try {
      await sendTextMessageRepository.call(textMessageEntity, channelId);
    } on SocketException catch (_) {
      emit(ChatFailure());
    } catch (_) {
      emit(ChatFailure());
    }
  }
}

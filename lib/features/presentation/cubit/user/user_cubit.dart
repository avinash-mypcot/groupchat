import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:self_host_group_chat_app/features/data/models/user_entity.dart';
import 'package:self_host_group_chat_app/features/data/repositories/get_all_users_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/get_update_user_repository.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetAllUsersRepository getAllUsersRepository;
  final GetUpdateUserRepository getUpdateUserRepository;
  UserCubit(
      {required this.getAllUsersRepository,
      required this.getUpdateUserRepository})
      : super(UserInitial());

  Future<void> getUsers() async {
    emit(UserLoading());
    final streamResponse = getAllUsersRepository.call();
    streamResponse.listen((users) {
      emit(UserLoaded(users: users));
    });
  }

  Future<void> getUpdateUser({required UserEntity user}) async {
    try {
      await getUpdateUserRepository.call(user);
    } on SocketException catch (_) {
      emit(UserFailure());
    } catch (_) {
      emit(UserFailure());
    }
  }
}

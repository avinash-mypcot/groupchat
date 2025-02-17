import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:self_host_group_chat_app/features/data/models/group_entity.dart';
import 'package:self_host_group_chat_app/features/data/repositories/create_group_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/get_all_group_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/join_group_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/update_group_repository.dart';
part 'group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  final GetCreateGroupUseCase getCreateGroupUseCase;
  final GetAllGroupsUseCase getAllGroupsUseCase;
  final JoinGroupUseCase joinGroupUseCase;
  final UpdateGroupUseCase groupUseCase;
  GroupCubit(
      {required this.groupUseCase,
      required this.joinGroupUseCase,
      required this.getCreateGroupUseCase,
      required this.getAllGroupsUseCase})
      : super(GroupInitial());

  Future<void> getGroups(String uId) async {
    emit(GroupLoading());

    final streamResponse = getAllGroupsUseCase.call();
    streamResponse.listen((groups) {
      // Filter groups where limitUsers contains the provided uId
      final filteredGroups = groups.where((group) {
        return group.limitUsers!.contains(uId);
      }).toList();

      emit(GroupLoaded(groups: filteredGroups));
    });
  }

  Future<void> getCreateGroup({required GroupEntity groupEntity}) async {
    log("IN GETCREATE GROUPE : ${groupEntity.limitUsers!.length}");
    try {
      await getCreateGroupUseCase.call(groupEntity);
    } on SocketException catch (_) {
      emit(GroupFailure());
    } catch (_) {
      emit(GroupFailure());
    }
  }

  Future<void> joinGroup({required GroupEntity groupEntity}) async {
    try {
      await joinGroupUseCase.call(groupEntity);
    } on SocketException catch (_) {
      emit(GroupFailure());
    } catch (_) {
      emit(GroupFailure());
    }
  }

  Future<void> updateGroup({required GroupEntity groupEntity}) async {
    try {
      await groupUseCase.call(groupEntity);
    } on SocketException catch (_) {
      emit(GroupFailure());
    } catch (_) {
      emit(GroupFailure());
    }
  }
}

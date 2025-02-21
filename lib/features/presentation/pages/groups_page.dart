import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_chat/features/data/models/user_model.dart';
import 'package:group_chat/features/data/models/group_entity.dart';
import 'package:group_chat/features/data/models/single_chat_entity.dart';
import 'package:group_chat/features/presentation/cubit/group/group_cubit.dart';
import 'package:group_chat/features/presentation/cubit/user/user_cubit.dart';
import 'package:group_chat/features/presentation/widgets/single_item_group_widget.dart';
import 'package:group_chat/core/routes/page_const.dart';
import 'package:group_chat/features/presentation/widgets/theme/style.dart';

import '../../../core/services/network/bloc/network_bloc.dart';

class GroupsPage extends StatelessWidget {
  final String uid;
  final String? query;

  const GroupsPage({Key? key, required this.uid, this.query}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: textIconColor,
        onPressed: () {
          Navigator.pushNamed(context, PageConst.createGroupPage,
              arguments: uid);
        },
        child: Icon(
          Icons.group_add,
          color: primaryColor,
        ),
      ),
      body: Stack(
        children: [
          BlocBuilder<UserCubit, UserState>(
            builder: (context, userState) {
              if (userState is UserLoaded) {
                final user = userState.users.firstWhere(
                    (element) => element.uid == uid,
                    orElse: () => UserModel());

                return BlocBuilder<GroupCubit, GroupState>(
                  builder: (context, groupState) {
                    if (groupState is GroupLoaded) {
                      final filteredGroups = groupState.groups
                          .where((group) =>
                              group.groupName.startsWith(query!) ||
                              group.groupName.startsWith(query!.toLowerCase()))
                          .toList();

                      return Column(
                        children: [
                          Expanded(
                              child: filteredGroups.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.group,
                                            size: 40,
                                            color: Colors.black.withOpacity(.4),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "No Group Created yet",
                                            style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(.2)),
                                          )
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: filteredGroups.length,
                                      itemBuilder: (_, index) {
                                        return SingleItemGroupWidget(
                                          group: filteredGroups[index],
                                          onTap: () {
                                            BlocProvider.of<GroupCubit>(context)
                                                .joinGroup(
                                                    groupEntity: GroupEntity(
                                                        groupId: filteredGroups[
                                                                index]
                                                            .groupId))
                                                .then((value) {
                                              BlocProvider.of<GroupCubit>(
                                                      context)
                                                  .getGroups(uid);
                                            });
                                            Navigator.pushNamed(context,
                                                PageConst.singleChatPage,
                                                arguments: SingleChatEntity(
                                                    username: user.name,
                                                    groupId:
                                                        filteredGroups[index]
                                                            .groupId,
                                                    groupName:
                                                        filteredGroups[index]
                                                            .groupName,
                                                    uid: uid));
                                          },
                                        );
                                      },
                                    ))
                        ],
                      );
                    }

                    return Center(child: CircularProgressIndicator());
                  },
                );
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          // BlocListener<NetworkBloc, NetworkState>(
          //   listener: (context, state) {
          //     if (state is NetworkFailure) {
          //       // Close any open bottom sheet
          //       if (Navigator.of(context).canPop()) {
          //         Navigator.of(context).pop();
          //       }
          //     }
          //   },
          //   child: BlocBuilder<NetworkBloc, NetworkState>(
          //     builder: (context, state) {
          //       if (state is NetworkFailure) {
          //         return Container(
          //           child: Text("NO INTERNATE"),
          //         );
          //       }

          //       return const SizedBox();
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:self_host_group_chat_app/features/data/api/storage_provider.dart';
import 'package:self_host_group_chat_app/features/data/models/group_entity.dart';
import 'package:self_host_group_chat_app/features/presentation/cubit/group/group_cubit.dart';
import 'package:self_host_group_chat_app/features/presentation/widgets/common.dart';
import 'package:self_host_group_chat_app/features/presentation/widgets/profile_widget.dart';
import 'package:self_host_group_chat_app/features/presentation/widgets/textfield_container.dart';
import 'package:self_host_group_chat_app/features/presentation/widgets/theme/style.dart';
import '../cubit/user/user_cubit.dart';

class CreateGroupPage extends StatefulWidget {
  final String uid;

  const CreateGroupPage({Key? key, required this.uid}) : super(key: key);
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _numberUsersJoinController = TextEditingController();

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  File? _image;
  String? _profileUrl;
  List<String> _selectedUserIds = []; // Store selected user IDs

  Future getImage() async {
    try {
      final pickedFile =
          await ImagePicker.platform.getImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          StorageProviderRemoteDataSource.uploadFile(file: _image!)
              .then((value) {
            setState(() {
              _profileUrl = value;
            });
          });
        }
      });
    } catch (e) {
      toast("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        title: Text("Create Group", style: TextStyle(color: Colors.white)),
      ),
      body: _bodyWidget(),
    );
  }

  Widget _bodyWidget() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 35),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                getImage();
              },
              child: Column(
                children: [
                  Container(
                    height: 62,
                    width: 62,
                    decoration: BoxDecoration(
                      color: color747480,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        child: profileWidget(image: _image)),
                  ),
                  SizedBox(height: 12),
                  Text('Add Group Image',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: primaryColor)),
                ],
              ),
            ),
            SizedBox(height: 17),
            TextFieldContainer(
              controller: _groupNameController,
              keyboardType: TextInputType.text,
              hintText: 'Group name',
              prefixIcon: Icons.edit,
            ),
            SizedBox(height: 10),
            _buildUserSelection(), // User selection widget
            SizedBox(height: 17),
            Divider(thickness: 2, indent: 120, endIndent: 120),
            SizedBox(height: 17),
            InkWell(
              onTap: () {
                _submit();
              },
              child: Container(
                alignment: Alignment.center,
                height: 44,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: primaryColor,
                ),
                child: Text('Create New Group',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSelection() {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        if (userState is UserLoaded) {
          final users =
              userState.users.where((user) => user.uid != widget.uid).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Users",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              users.isEmpty
                  ? Center(child: Text("No Users Found"))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (_, index) {
                        final user = users[index];
                        return CheckboxListTile(
                          title: Text(user.name),
                          value: _selectedUserIds.contains(user.uid),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedUserIds.add(user.uid);
                              } else {
                                _selectedUserIds.remove(user.uid);
                              }
                            });
                          },
                        );
                      },
                    ),
            ],
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  _submit() {
    if (_image == null) {
      toast('Add profile photo');
      return;
    }
    if (_groupNameController.text.isEmpty) {
      toast('Enter group name');
      return;
    }
    if (_selectedUserIds.isEmpty) {
      toast('Select at least one user');
      return;
    }
_selectedUserIds.add(widget.uid);
    BlocProvider.of<GroupCubit>(context).getCreateGroup(
      groupEntity: GroupEntity(
        lastMessage: "",
        uid: widget.uid,
        groupName: _groupNameController.text,
        creationTime: Timestamp.now(),
        groupProfileImage: _profileUrl ?? '',
        joinUsers:
            _selectedUserIds.join(','), // Storing UIDs as comma-separated
        limitUsers: _selectedUserIds,
      ),
    );
    toast("${_groupNameController.text} created successfully");
    _clear();
  }

  void _clear() {
    setState(() {
      _groupNameController.clear();
      _profileUrl = "";
      _image = null;
      _selectedUserIds.clear();
    });
  }
}

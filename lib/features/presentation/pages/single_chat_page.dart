import 'dart:async';
import 'dart:developer';

import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:group_chat/features/data/models/group_entity.dart';
import 'package:group_chat/features/data/models/single_chat_entity.dart';
import 'package:group_chat/features/presentation/cubit/chat/chat_cubit.dart';
import 'package:group_chat/features/presentation/cubit/group/group_cubit.dart';

import '../../../core/services/hive/hive_model.dart';
import '../widgets/theme/style.dart';

class SingleChatPage extends StatefulWidget {
  final SingleChatEntity singleChatEntity;
  const SingleChatPage({Key? key, required this.singleChatEntity})
      : super(key: key);

  @override
  _SingleChatPageState createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
  OverlayEntry? _popupEntry;
  bool _isDisappearingEnabled = false; // Store the disappearing message state
  int _disappearTime = 2; // Default disappearing time in minutes
  String _timeUnit = 'Minutes';
  String messageContent = "";
  bool isEnableDis = false;
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _messageController.addListener(() {
      setState(() {});
    });
    BlocProvider.of<ChatCubit>(context)
        .getMessages(channelId: widget.singleChatEntity.groupId);
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  DateTime setExpirationTime(int duration, String timeUnit) {
    int milliseconds = 0;

    if (timeUnit == "Minutes") {
      milliseconds = Duration(minutes: duration).inMilliseconds;
    } else if (timeUnit == "Hours") {
      milliseconds = Duration(hours: duration).inMilliseconds;
    } else if (timeUnit == "Days") {
      milliseconds = Duration(days: duration).inMilliseconds;
    } else if (timeUnit == "Weeks") {
      milliseconds =
          Duration(days: duration * 7).inMilliseconds; // 1 week = 7 days
    } else {
      throw ArgumentError(
          "Invalid time unit. Use 'minutes', 'hours', 'days', or 'weeks'.");
    }

    // Calculate the expiration time by adding the specified time duration to the current time
    return DateTime.fromMillisecondsSinceEpoch(
      Timestamp.now().millisecondsSinceEpoch + milliseconds,
    );
  }

  void _showPopup(BuildContext context, Offset position) {
    _popupEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Tap detector to dismiss the popup
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _removePopup();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(),
            ),
          ),

          // The popup menu
          Positioned(
            top: position.dy,
            right: 10,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _popupItem("Enable Disappearing Messages", Icons.timer, () {
                      _showDisappearingDialog(context);
                      _removePopup();
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_popupEntry!);
  }

  // Helper to display a dialog for selecting disappearing time
  void _showDisappearingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Use StatefulBuilder to manage state within the dialog
          builder: (context, setState) {
            // Debugging print statements to check values
            print('Time: $_disappearTime $_timeUnit');

            return AlertDialog(
              title: Text('Set Disappearing Message Time'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown for time unit selection
                  DropdownButton<String>(
                    value: _timeUnit,
                    onChanged: (String? newValue) {
                      setState(() {
                        _timeUnit = newValue!;
                        _disappearTime =
                            1; // Reset time to 1 when changing the unit
                        print('Selected unit: $_timeUnit');
                      });
                    },
                    items: <String>['Minutes', 'Hours', 'Days', 'Weeks']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  Slider(
                    value: _disappearTime.toDouble(),
                    min: 1,
                    max: (_timeUnit == 'Weeks')
                        ? 4
                        : 24, // Weeks can have up to 4
                    divisions: (_timeUnit == 'Weeks') ? 4 : 24,
                    label: '$_disappearTime $_timeUnit',
                    onChanged: (value) {
                      setState(() {
                        _disappearTime = value.toInt();
                        log('Slider value changed: $_disappearTime');
                      });
                    },
                  ),
                  // Display the selected duration
                  Text('$_disappearTime $_timeUnit'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      isEnableDis = true;
                      _isDisappearingEnabled =
                          true; // Enable disappearing messages
                    });
                    Navigator.pop(context);
                    print(
                        "Disappearing messages enabled for $_disappearTime $_timeUnit");
                  },
                  child: Text('Enable'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _popupItem(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            SizedBox(width: 10),
            Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }

  void _removePopup() {
    _popupEntry?.remove();
    _popupEntry = null;
  }

  check() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: textIconColor,
        title: Text(
          "${widget.singleChatEntity.groupName}",
          style: TextStyle(color: textIconColor),
        ),
        backgroundColor: primaryColor,
        actions: [
          GestureDetector(
            onTapDown: (details) {
              _showPopup(context, details.globalPosition);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (index, chatState) {
          if (chatState is ChatLoaded) {
            return Column(
              children: [
                _messagesListWidget(chatState),
                _sendMessageTextField(),
              ],
            );
          } else if (chatState is ChatFailure) {
            return Center(child: Text('FALIED'));
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _sendMessageTextField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 4, right: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(80)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.2),
                      offset: Offset(0.0, 0.50),
                      spreadRadius: 1,
                      blurRadius: 1,
                    )
                  ]),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  // Icon(
                  //   Icons.insert_emoticon,
                  //   color: Colors.grey[500],
                  // ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 60),
                        child: Scrollbar(
                          child: TextField(
                            style: TextStyle(fontSize: 14),
                            controller: _messageController,
                            maxLines: null,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Type a message"),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Row(
                  //   children: [
                  //     Icon(
                  //       Icons.link,
                  //       color: Colors.grey[500],
                  //     ),
                  //     SizedBox(
                  //       width: 10,
                  //     ),
                  //     _messageController.text.isEmpty
                  //         ? Icon(
                  //             Icons.camera_alt,
                  //             color: Colors.grey[500],
                  //           )
                  //         : Text(""),
                  //   ],
                  // ),
                  SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          InkWell(
            onTap: () {
              if (_messageController.text.isEmpty) {
              } else {
                print(_messageController.text);
                BlocProvider.of<ChatCubit>(context).sendTextMessage(
                    textMessageEntity: TextMessageModel(
                        messageId: '',
                        expiredAt: isEnableDis
                            ? setExpirationTime(_disappearTime, _timeUnit)
                            : DateTime(2030),
                        time: DateTime.now(),
                        senderId: widget.singleChatEntity.uid,
                        content: _messageController.text,
                        senderName: widget.singleChatEntity.username,
                        type: "TEXT",
                        receiverName: '',
                        recipientId: ''),
                    channelId: widget.singleChatEntity.groupId);
                BlocProvider.of<GroupCubit>(context).updateGroup(
                    groupEntity: GroupEntity(
                  groupId: widget.singleChatEntity.groupId,
                  lastMessage: _messageController.text,
                  creationTime: Timestamp.now(),
                ));
                setState(() {
                  _messageController.clear();
                });
              }
            },
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: Icon(
                // _messageController.text.isEmpty ? Icons.mic :
                Icons.send,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _messagesListWidget(ChatLoaded messages) {
    Timer(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInQuad,
      );
    });

    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: messages.messages.length,
        itemBuilder: (_, index) {
          final message = messages.messages[index];

          // Convert to local time based on the device's timezone
          final localTime = message.time!.toLocal();
          final formattedTime = DateFormat('hh:mm a').format(localTime);

          if (message.senderId == widget.singleChatEntity.uid) {
            return _messageLayout(
              name: "Me",
              alignName: TextAlign.end,
              color: primaryColor.withOpacity(0.5),
              time: formattedTime,
              align: TextAlign.left,
              boxAlign: CrossAxisAlignment.start,
              crossAlign: CrossAxisAlignment.end,
              nip: BubbleNip.rightTop,
              text: message.content,
            );
          } else {
            return _messageLayout(
              color: Colors.white,
              name: "${message.senderName}",
              alignName: TextAlign.end,
              time: formattedTime,
              align: TextAlign.left,
              boxAlign: CrossAxisAlignment.start,
              crossAlign: CrossAxisAlignment.start,
              nip: BubbleNip.leftTop,
              text: message.content,
            );
          }
        },
      ),
    );
  }

  Widget _messageLayout({
    text,
    time,
    color,
    align,
    boxAlign,
    nip,
    crossAlign,
    String? name,
    alignName,
  }) {
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.90,
          ),
          child: Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.all(3),
            child: Bubble(
              color: color,
              nip: nip,
              child: Column(
                crossAxisAlignment: crossAlign,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$name",
                    textAlign: alignName,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    text,
                    textAlign: align,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    time,
                    textAlign: align,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(
                        .4,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

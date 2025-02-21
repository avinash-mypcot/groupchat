import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../hive/hive_model.dart';
import '../services/network_services.dart';
part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  NetworkBloc._() : super(NetworkInitial()) {
    on<NetworkObserve>(_observe);
    on<NetworkNotify>(_notifyStatus);
  }

  static final NetworkBloc _instance = NetworkBloc._();

  factory NetworkBloc() => _instance;

  // void _observe(NetworkObserve event, Emitter<NetworkState> emit) {
  //   NetworkService.observeNetwork().listen((isConnected) {
  //     add(NetworkNotify(isConnected: isConnected));
  //   });
  // }

  void _observe(NetworkObserve event, Emitter<NetworkState> emit) {
    NetworkService.observeNetwork().listen((isConnected) {
      add(NetworkNotify(isConnected: isConnected));
      if (isConnected) {
        _syncLocalMessages();
      }
    });
  }

  void _notifyStatus(NetworkNotify event, emit) {
    event.isConnected ? emit(NetworkSuccess()) : emit(NetworkFailure());
  }
}

Future<void> _syncLocalMessages() async {
  log("IN SYNC");
  var keys = await Hive.box<TextMessageModel>('messages').keys; // Get all stored keys
  for (var key in keys) {
    var box = await Hive.box<TextMessageModel>(key);
    for (var message in box.values) {
      await FirebaseFirestore.instance
          .collection("groupChatChannel")
          .doc(key)
          .collection("messages")
          .doc(message.messageId)
          .set(message.toDocument());
    }
    // await box.clear(); // Clear local storage after syncing
  }
}

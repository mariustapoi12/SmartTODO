import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:smattodo/src/model/task.dart';
import 'package:smattodo/src/model/logger.dart';

void onConnectCallback(StompFrame frame) {
  log.w("STOMP Client connected");

  stompClient.subscribe(
    destination: "/broker/added-task",
    callback: (frame) {
      log.w("Received new added task from server");

      Task.fromJson(jsonDecode(frame.body!));
      // Perform actions with the added task as needed
    },
  );

  stompClient.subscribe(
    destination: "/broker/edited-task",
    callback: (frame) {
      log.w("Received updated task from server");
      log.w(frame.body);

      Task.fromJson(jsonDecode(frame.body!));
      // Perform actions with the updated task as needed
    },
  );

  stompClient.subscribe(
    destination: "/broker/deleted-task",
    callback: (frame) {
      log.w("Received deleted task from server");
      log.w(frame.body);

      int.parse(frame.body!);
      // Perform actions with the deleted task ID as needed
    },
  );
}

final StompClient stompClient = StompClient(
  config: const StompConfig(
    url: "ws://10.0.2.2:8080/server",
    onConnect: onConnectCallback,
  ),
);

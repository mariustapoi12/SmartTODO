import 'package:flutter/material.dart';
import 'package:smattodo/src/api/api.dart';
import 'package:smattodo/src/repository/repository.dart';
import 'package:smattodo/src/database/database.dart';
import 'src/app.dart';
import 'src/stomp/stomp_client_config.dart';
// import 'package:smattodo/src/model/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  final database = await $FloorTaskDatabase
      .databaseBuilder('app_database2.db')
      .addMigrations([migration1to2]).build();

  // Create a TaskRepository with the TaskDAO
  final taskRepository = TaskRepository(
      api: Api(apiBaseUrl: "http://10.0.2.2:8080/api"), taskDatabase: database);

  // final task1 = Task(
  //   //id: 200,
  //   //serverId: 200,
  //   title: "Wash dishes",
  //   description: "Wash dishes with fairy",
  //   priority: "Minor",
  //   status: "Past Due",
  //   duedate: DateTime.parse('2023-10-30 21:30:00').millisecondsSinceEpoch,
  // );
  // final task2 = Task(
  //   //id: 201,
  //   //serverId: 201,
  //   title: "Go to job",
  //   description: "Str. Constanta 30-34",
  //   priority: "Critical",
  //   status: "Done",
  //   duedate: DateTime.parse('2023-10-30 08:00:00').millisecondsSinceEpoch,
  // );
  // final task3 = Task(
  //   //id: 202,
  //   //serverId: 202,
  //   title: "Go to uni",
  //   description: "Attend Mobile Lab",
  //   priority: "Major",
  //   status: "TO-DO",
  //   duedate: DateTime.parse('2023-10-31 12:00:00').millisecondsSinceEpoch,
  // );
  // final task4 = Task(
  //   //id: 203,
  //   //serverId: 203,
  //   title: "Go to football",
  //   description: "Gheorgheni Sport Complex",
  //   priority: "Important",
  //   status: "Done",
  //   duedate: DateTime.parse('2023-10-14 13:00:00').millisecondsSinceEpoch,
  // );
  // final task5 = Task(
  //   //id: 204,
  //   //serverId: 204,
  //   title: "Read",
  //   description: "Read 'Harap-Alb'",
  //   priority: "Trivial",
  //   status: "TO-DO",
  //   duedate: DateTime.parse('2023-11-30 20:20:00').millisecondsSinceEpoch,
  // );

  // taskDao.instertTask(task1);
  // taskDao.instertTask(task2);
  // taskDao.instertTask(task3);
  // taskDao.instertTask(task4);
  // taskDao.instertTask(task5);

  // taskRepository.addTaskOffline(task1);
  // taskRepository.addTaskOffline(task2);
  // taskRepository.addTaskOffline(task3);
  // taskRepository.addTaskOffline(task4);
  // taskRepository.addTaskOffline(task5);

  stompClient.activate();

  runApp(MyApp(taskRepository: taskRepository));
}

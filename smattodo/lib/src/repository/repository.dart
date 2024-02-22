import 'package:smattodo/src/model/task.dart';
import 'package:smattodo/src/stomp/stomp_client_config.dart';
import 'package:smattodo/src/database/database.dart';
import 'package:smattodo/src/api/api.dart';

class TaskRepository {
  final IApi api;
  final TaskDatabase taskDatabase;

  TaskRepository({required this.api, required this.taskDatabase});

  Future<void> synchronizeServerWithLocalDB() async {
    stompClient.deactivate();

    // Fetch tasks from the local database that are not added to the server
    final listOfTasksNotAddedToServer =
        await taskDatabase.taskDao.getTasksNotAddedToServer();

    // Iterate over tasks not added to the server
    await Future.forEach(
      listOfTasksNotAddedToServer,
      (taskNotAddedToServer) async {
        try {
          // Call the API to add the task to the server
          final taskAddedToServer = await api.addTask(taskNotAddedToServer);

          // Update the local database with the server ID
          await taskDatabase.taskDao.setServerIdForGivenTaskId(
            taskNotAddedToServer.id!,
            taskAddedToServer.id!,
          );
        } catch (error) {
          // Handle offline scenario here
          print("Offline: Unable to sync task with the server.");
        }
      },
    );

    stompClient.activate();
  }

  // Online method: Adds the task to the server and local database
  Future<Task> addTaskOnline(Task task) async {
    try {
      await taskDatabase.taskDao.instertTask(task);
      print('Added task locally!');
      return task;
    } catch (error) {
      // Handle offline scenario here
      print("Offline: Unable to add task to the server.");
      print(task);
      rethrow;
    }
  }

  // Offline method: Adds the task only to the local database
  Future<void> addTaskOffline(Task task) async {
    await taskDatabase.taskDao.instertTask(task);
  }

  Future<void> updateTask(Task task) async {
    await taskDatabase.taskDao.updateTaskGivenServerId(
      task.id!,
      task.title,
      task.description,
      task.priority,
      task.status,
      task.duedate,
    );
    await api.updateTask(task);
  }

  Future<List<Task>> getTasksFromServer() async {
    await synchronizeServerWithLocalDB();
    // uncomment this if you want to get data directly from server
    // it is unsorted though
    final serverTaskList = await api.getAllTasks();
    // final serverTaskList = await taskDatabase.taskDao.findAllTasks();
    return serverTaskList;
  }

  Future<void> removeTask(Task task) async {
    await taskDatabase.taskDao.removeTaskWithGivenServerId(task.id!);
    await api.deleteTask(task.id!);
  }

  Future<List<Task>> getTasksFromLocal() async {
    return await taskDatabase.taskDao.findAllTasks();
  }
}

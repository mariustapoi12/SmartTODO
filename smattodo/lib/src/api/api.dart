import 'package:smattodo/src/model/task.dart';
import 'package:dio/dio.dart';
import 'package:smattodo/src/model/httplogger.dart';

abstract class IApi {
  Future<List<Task>> getAllTasks();
  Future<Task> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(int id);
}

class Api implements IApi {
  final Dio _dio;

  Api({
    required String apiBaseUrl,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: apiBaseUrl,
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
          ),
        ) {
    _dio.interceptors.add(HttpLogger());
  }

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      final response = await _dio.get("/tasks");
      return response.data
          .map<Task>(
            (taskJSON) => Task.fromJson(taskJSON),
          )
          .toList();
    } catch (exception) {
      rethrow;
    }
  }

  @override
  Future<Task> addTask(Task task) async {
    try {
      final response = await _dio.post(
        "/tasks",
        data: task.toJson(),
      );
      return Task.fromJson(response.data);
    } catch (exception) {
      rethrow;
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      await _dio.put(
        "/tasks",
        data: task.toJson(),
      );
    } catch (exception) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    try {
      await _dio.delete("/tasks/$id");
    } catch (exception) {
      rethrow;
    }
  }
}

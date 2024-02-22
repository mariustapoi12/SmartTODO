import 'package:floor/floor.dart';

@entity
class Task {
  @primaryKey
  final int? id;
  int? serverId;
  String title;
  String description;
  String priority;
  String status;
  int duedate;

  Task({
    this.id,
    this.serverId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.duedate,
  });

  // Convert Task object to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'dueDate': duedate, // Change this line
    };
  }

// Create a Task object from a Map
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
      duedate: json['dueDate'],
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return this.id.toString() +
        ' ' +
        this.serverId.toString() +
        this.title +
        ' ' +
        this.description;
  }
}

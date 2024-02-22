import 'package:floor/floor.dart';
import 'task.dart';

@dao
abstract class TaskDAO {
  @Query(
      'SELECT * FROM Task ORDER BY CASE status WHEN "TO-DO" THEN 1 WHEN "Past Due" THEN 2 WHEN "Done" THEN 3 ELSE 4 END, CASE priority WHEN "Critical" THEN 1 WHEN "Major" THEN 2 WHEN "Important" THEN 3 WHEN "Minor" THEN 4 WHEN "Trivial" THEN 5 ELSE 6 END, duedate')
  Future<List<Task>> findAllTasks();

  @insert
  Future<void> instertTask(Task task);

  @Query(
      "UPDATE Task SET title = :title, description = :description, priority = :priority, status = :status, duedate = :duedate WHERE serverId = :serverId")
  Future<void> updateTaskGivenServerId(
    int serverId,
    String title,
    String description,
    String priority,
    String status,
    int duedate,
  );
  @Query("DELETE FROM Task WHERE serverId = :serverId")
  Future<void> removeTaskWithGivenServerId(int serverId);

  @Query("SELECT * FROM Task WHERE serverId IS NULL")
  Future<List<Task>> getTasksNotAddedToServer();

  @Query("UPDATE Task SET serverId = :serverId WHERE id = :id")
  Future<void> setServerIdForGivenTaskId(int id, int serverId);
}

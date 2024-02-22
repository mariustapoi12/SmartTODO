// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorTaskDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$TaskDatabaseBuilder databaseBuilder(String name) =>
      _$TaskDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$TaskDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$TaskDatabaseBuilder(null);
}

class _$TaskDatabaseBuilder {
  _$TaskDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$TaskDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$TaskDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<TaskDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$TaskDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$TaskDatabase extends TaskDatabase {
  _$TaskDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  TaskDAO? _taskDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Task` (`id` INTEGER, `serverId` INTEGER, `title` TEXT NOT NULL, `description` TEXT NOT NULL, `priority` TEXT NOT NULL, `status` TEXT NOT NULL, `duedate` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  TaskDAO get taskDao {
    return _taskDaoInstance ??= _$TaskDAO(database, changeListener);
  }
}

class _$TaskDAO extends TaskDAO {
  _$TaskDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _taskInsertionAdapter = InsertionAdapter(
            database,
            'Task',
            (Task item) => <String, Object?>{
                  'id': item.id,
                  'serverId': item.serverId,
                  'title': item.title,
                  'description': item.description,
                  'priority': item.priority,
                  'status': item.status,
                  'duedate': item.duedate
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Task> _taskInsertionAdapter;

  @override
  Future<List<Task>> findAllTasks() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Task ORDER BY CASE status WHEN \"TO-DO\" THEN 1 WHEN \"Past Due\" THEN 2 WHEN \"Done\" THEN 3 ELSE 4 END, CASE priority WHEN \"Critical\" THEN 1 WHEN \"Major\" THEN 2 WHEN \"Important\" THEN 3 WHEN \"Minor\" THEN 4 WHEN \"Trivial\" THEN 5 ELSE 6 END, duedate',
        mapper: (Map<String, Object?> row) => Task(
            id: row['id'] as int?,
            serverId: row['serverId'] as int?,
            title: row['title'] as String,
            description: row['description'] as String,
            priority: row['priority'] as String,
            status: row['status'] as String,
            duedate: row['duedate'] as int));
  }

  @override
  Future<void> updateTaskGivenServerId(
    int serverId,
    String title,
    String description,
    String priority,
    String status,
    int duedate,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Task SET title = ?2, description = ?3, priority = ?4, status = ?5, duedate = ?6 WHERE serverId = ?1',
        arguments: [serverId, title, description, priority, status, duedate]);
  }

  @override
  Future<void> removeTaskWithGivenServerId(int serverId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM Task WHERE serverId = ?1',
        arguments: [serverId]);
  }

  @override
  Future<List<Task>> getTasksNotAddedToServer() async {
    return _queryAdapter.queryList('SELECT * FROM Task WHERE serverId IS NULL',
        mapper: (Map<String, Object?> row) => Task(
            id: row['id'] as int?,
            serverId: row['serverId'] as int?,
            title: row['title'] as String,
            description: row['description'] as String,
            priority: row['priority'] as String,
            status: row['status'] as String,
            duedate: row['duedate'] as int));
  }

  @override
  Future<void> setServerIdForGivenTaskId(
    int id,
    int serverId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Task SET serverId = ?2 WHERE id = ?1',
        arguments: [id, serverId]);
  }

  @override
  Future<void> instertTask(Task task) async {
    print('Trying to insert a task!');
    await _taskInsertionAdapter.insert(task, OnConflictStrategy.abort);
    print('INSERTED! :D');
  }
}

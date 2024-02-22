// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../model/task.dart';
import '../model/taskdao.dart';

part 'database.g.dart'; // the generated code will be there

final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE Task ADD COLUMN serverId INTEGER');
});

@Database(version: 2, entities: [Task])
abstract class TaskDatabase extends FloorDatabase {
  TaskDAO get taskDao;
}

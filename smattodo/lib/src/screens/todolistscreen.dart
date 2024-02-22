import 'package:flutter/material.dart';
import 'package:smattodo/src/repository/repository.dart';
import 'package:smattodo/src/model/task.dart';
import 'package:smattodo/src/screens/addupdatescreen.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:web_socket_channel/io.dart';

class TodoListScreen extends StatefulWidget {
  final TaskRepository todoListViewModel;

  TodoListScreen({required this.todoListViewModel});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  bool isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkNetworkStatus();

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _handleConnectivityChange(result);
    });

    // Sync with the server when connectivity is restored
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isOnline) {
        _syncWithServer();
      }
    });
  }

  Future<void> _syncWithServer() async {
    final channel = IOWebSocketChannel.connect('ws://10.0.2.2:8080/server');

    channel.sink.add('GetTasks:{}');

    // Listen for updates from the server
    channel.stream.listen((message) {
      // Parse the message and update local data if needed
      // For example: _handleServerUpdate(message);
      print('Received message from server: $message');
      _updateScreen();
    });

    // Close the channel when done
    channel.sink.close();
  }

  Future<void> _checkNetworkStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _handleConnectivityChange(connectivityResult);
  }

  void _handleConnectivityChange(ConnectivityResult connectivityResult) {
    setState(() {
      isOnline = connectivityResult != ConnectivityResult.none;
    });

    // If connectivity is restored, refresh the data
    if (isOnline) {
      _updateScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SmartTODO'),
        actions: [
          ElevatedButton.icon(
            label: Text("Add task"),
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskFromScreen(
                    onSaveClicked: (Task addedTask) async {
                      if (isOnline) {
                        print("ADEDD TASK:");
                        print(addedTask.title);
                        print(addedTask.duedate);
                        await widget.todoListViewModel.addTaskOnline(addedTask);
                      } else
                        await widget.todoListViewModel
                            .addTaskOffline(addedTask);
                      Navigator.pop(context, addedTask);
                      _updateScreen();
                    },
                    onCancelClicked: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
              _updateScreen();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<Task>>(
      future: isOnline
          ? widget.todoListViewModel.getTasksFromServer()
          : widget.todoListViewModel.getTasksFromLocal(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          final todoList = snapshot.data ?? [];
          return _buildTodoList(todoList);
        } else {
          final todoList = snapshot.data!;
          return _buildTodoList(todoList);
        }
      },
    );
  }

  Widget _buildTodoList(List<Task> todoList) {
    return Column(
      children: [
        if (!isOnline)
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.yellow,
            child: Text(
              'Offline mode: Showing local data.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: todoList.length,
            itemBuilder: (BuildContext context, int index) {
              final task = todoList[index];
              return TaskListItem(
                task: task,
                onTaskClicked: () async {
                  if (isOnline) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskFromScreen(
                          task: task,
                          onSaveClicked: (Task updatedTask) {
                            widget.todoListViewModel.updateTask(updatedTask);
                            Navigator.pop(context, updatedTask);
                          },
                          onCancelClicked: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                    _updateScreen();
                  } else {
                    _showOfflineMessage();
                  }
                },
                onDeleteClicked: () {
                  if (isOnline) {
                    showConfirmationDialog(
                      context,
                      onContinueClicked: () async {
                        widget.todoListViewModel.removeTask(task);
                        Navigator.pop(context);
                        _updateScreen();
                      },
                    );
                  } else {
                    _showOfflineMessage();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showOfflineMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Offline mode: Operation not available.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showConfirmationDialog(BuildContext context,
      {required VoidCallback onContinueClicked}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: onContinueClicked,
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _updateScreen() {
    setState(() {});
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTaskClicked;
  final VoidCallback onDeleteClicked;

  TaskListItem({
    required this.task,
    required this.onTaskClicked,
    required this.onDeleteClicked,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (task.status == 'TO-DO') {
      statusColor = Colors.yellow;
    } else if (task.status == 'Done') {
      statusColor = Color.fromARGB(255, 31, 255, 39);
    } else if (task.status == 'Past Due') {
      statusColor = Colors.red;
    }

    String formattedDueDate = DateFormat.yMd().add_Hm().format(
          DateTime.fromMillisecondsSinceEpoch(task.duedate),
        );

    return Card(
      color: const Color.fromARGB(255, 41, 151, 241),
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: onTaskClicked,
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.description,
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Priority: ${task.priority}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Status: ${task.status}',
                style: TextStyle(color: statusColor),
              ),
              Text(
                'Due date: $formattedDueDate',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: onDeleteClicked,
          ),
        ),
      ),
    );
  }
}

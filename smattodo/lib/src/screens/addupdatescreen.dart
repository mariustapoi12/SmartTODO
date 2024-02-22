import 'package:flutter/material.dart';
import 'package:smattodo/src/model/task.dart';
import 'package:intl/intl.dart';

class TaskFromScreen extends StatefulWidget {
  final Task? task;
  // Function that takes a task as argument
  final void Function(Task) onSaveClicked;
  final VoidCallback onCancelClicked;

  TaskFromScreen({
    required this.onSaveClicked,
    required this.onCancelClicked,
    this.task,
  });

  @override
  _TaskFromScreenState createState() => _TaskFromScreenState();
}

class _TaskFromScreenState extends State<TaskFromScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController priorityController;
  late TextEditingController statusController;
  late TextEditingController dueDateController;

  List<String> priorityOptions = [
    'Trivial',
    'Minor',
    'Important',
    'Major',
    'Critical'
  ];
  List<String> statusOptions = ['Done', 'TO-DO', 'Past Due'];

  @override
  void initState() {
    // Create the screen with empty title, description and date
    // and witg priority set by default to Important and statuts TO-DO
    super.initState();

    titleController = TextEditingController(text: widget.task?.title ?? '');
    descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    priorityController =
        TextEditingController(text: widget.task?.priority ?? 'Important');
    statusController =
        TextEditingController(text: widget.task?.status ?? 'TO-DO');
    dueDateController = TextEditingController(
      text: widget.task?.duedate.toString() ?? '',
    );

    // Check if the task has a due date and format it without seconds and milliseconds
    if (widget.task?.duedate != null) {
      final dueDateTime =
          DateTime.fromMillisecondsSinceEpoch(widget.task!.duedate);
      dueDateController.text =
          DateFormat("yyyy-MM-dd HH:mm").format(dueDateTime);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priorityController.dispose();
    statusController.dispose();
    dueDateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Title specific for adding or updating a task
        title: Text(widget.task == null ? 'Add Task' : 'Update Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 16),
              // Dropdown for priority
              DropdownButtonFormField<String>(
                value: priorityController.text,
                decoration: InputDecoration(labelText: 'Priority'),
                items: priorityOptions.map((String priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    priorityController.text = value ?? '';
                  });
                },
              ),
              SizedBox(height: 16),
              // Dropdown for status
              DropdownButtonFormField<String>(
                value: statusController.text,
                decoration: InputDecoration(labelText: 'Status'),
                items: statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    statusController.text = value ?? '';
                  });
                },
              ),
              SizedBox(height: 16),
              // TextField for the due date
              TextFormField(
                controller: dueDateController,
                readOnly: true, // Set to true to make the field read-only
                // This way we prevent the user from inputing invalid dates
                onTap: () async {
                  // Calendar which sets the date time to the current one
                  // User can select dates from 1901 to 2100
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1901),
                    lastDate: DateTime(2100),
                  );

                  if (selectedDate != null) {
                    // Clock to pick the time
                    TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    // If the time was selected, we fill the field
                    if (selectedTime != null) {
                      DateTime selectedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      // Format the DateTime to display without seconds and milliseconds
                      String formattedDateTime = DateFormat("yyyy-MM-dd HH:mm")
                          .format(selectedDateTime);

                      setState(() {
                        dueDateController.text = formattedDateTime;
                      });
                    }
                  }
                },
                decoration: InputDecoration(labelText: 'Due Date'),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Add a border
                  borderRadius: BorderRadius.circular(8.0), // Add border radius
                ),
                child: TextFormField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    contentPadding: EdgeInsets.all(8.0), // Adjust padding
                    border: InputBorder.none, // Remove border
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Check if the title is not empty
                      if (titleController.text.trim().isEmpty) {
                        // Show an alert when the title is empty
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text('Title cannot be empty.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the alert
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }

                      // Check if the due date is not empty
                      if (dueDateController.text.trim().isEmpty) {
                        // Show an alert when the due date is empty
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text('Due date cannot be empty.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the alert
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }

                      // Continue with saving the task
                      Task task;
                      if (widget.task == null) {
                        // Create a new task
                        task = Task(
                          title: titleController.text,
                          description: descriptionController.text,
                          priority: priorityController.text,
                          status: statusController.text,
                          duedate: DateTime.parse(dueDateController.text)
                              .millisecondsSinceEpoch,
                        );
                      } else {
                        // Update the existing task
                        task = Task(
                          id: widget.task!.id,
                          title: titleController.text,
                          description: descriptionController.text,
                          priority: priorityController.text,
                          status: statusController.text,
                          duedate: DateTime.parse(dueDateController.text)
                              .millisecondsSinceEpoch,
                        );
                      }

                      // Add or update the task
                      widget.onSaveClicked(task);
                    },
                    child: Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: widget.onCancelClicked,
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

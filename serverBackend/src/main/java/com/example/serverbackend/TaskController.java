package com.example.serverbackend;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.user.SimpUserRegistry;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/tasks")
public class TaskController {
    private SimpMessagingTemplate messagingTemplate;
    private SimpUserRegistry simpUserRegistry;
    private TaskService taskService;

    @Autowired
    public TaskController(TaskService taskService, SimpMessagingTemplate messagingTemplate, SimpUserRegistry simpUserRegistry) {
        this.taskService = taskService;
        this.messagingTemplate = messagingTemplate;
        this.simpUserRegistry = simpUserRegistry;
    }

    @GetMapping
    public ResponseEntity<Object> getAllTasks() {
        return new ResponseEntity<>(taskService.getTasks(), HttpStatus.OK);
    }

    @PostMapping
    public ResponseEntity<Object> addTask(@RequestBody Task taskToAdd) {
        System.out.println(taskToAdd);
        var addedTask = taskService.saveTask(taskToAdd);

        messagingTemplate.convertAndSend("/broker/added-task", addedTask);

        return new ResponseEntity<>(addedTask, HttpStatus.CREATED);
    }

    @PutMapping
    public ResponseEntity<Object> updateTask(@RequestBody Task task) {
        taskService.updateTask(task);

        messagingTemplate.convertAndSend("/broker/edited-task", task);

        return new ResponseEntity<>("Task updated successfully", HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Object> deleteTask(@PathVariable Long id) {
        taskService.deleteById(id);

        messagingTemplate.convertAndSend("/broker/deleted-task", id);

        return new ResponseEntity<>("Task deleted successfully", HttpStatus.OK);
    }
}

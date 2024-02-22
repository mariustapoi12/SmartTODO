package com.example.serverbackend;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class TaskService {
    @Autowired
    private TaskRepository taskRepository;

    public List<Task> getTasks() {
        return taskRepository.findAllOrdered();
    }

    public Optional<Task> deleteById(Long id) {
        Optional<Task> taskListing = taskRepository.findById(id);
        if(taskListing.isPresent())
            taskRepository.deleteById(id);
        return taskListing;
    }

    public Task saveTask(Task task) {
        return taskRepository.save(task);
    }
    public void updateTask(Task task){
        taskRepository.findById(task.getId()).map(taskToUpdate -> {
            taskToUpdate.setTitle(task.getTitle());
            taskToUpdate.setStatus(task.getStatus());
            taskToUpdate.setPriority(task.getPriority());
            taskToUpdate.setDueDate(task.getDueDate());
            taskToUpdate.setDescription(task.getDescription());
            return taskRepository.save(taskToUpdate);
        }).orElseGet(() -> taskRepository.save(task));
    }
}

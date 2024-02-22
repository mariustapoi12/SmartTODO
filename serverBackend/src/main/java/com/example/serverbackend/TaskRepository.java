package com.example.serverbackend;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface TaskRepository extends JpaRepository <Task, Long>{
    @Query("SELECT t FROM Task t " +
            "ORDER BY " +
            "CASE t.status WHEN 'TO-DO' THEN 1 WHEN 'Past Due' THEN 2 WHEN 'Done' THEN 3 ELSE 4 END, " +
            "CASE t.priority WHEN 'Critical' THEN 1 WHEN 'Major' THEN 2 WHEN 'Important' THEN 3 WHEN 'Minor' THEN 4 WHEN 'Trivial' THEN 5 ELSE 6 END, " +
            "t.duedate")
    List<Task> findAllOrdered();
}

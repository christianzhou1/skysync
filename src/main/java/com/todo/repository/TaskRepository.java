package com.todo.repository;

import com.todo.entity.Task;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TaskRepository extends JpaRepository<Task, UUID> {
    List<Task> findAllByDeletedFalseOrderByCreatedAtDesc();
    Optional<Task> findByIdAndDeletedFalse(UUID id);
}

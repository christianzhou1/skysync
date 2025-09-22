package com.todo.repository;

import com.todo.entity.Task;
import org.hibernate.Incubating;
import org.springframework.data.domain.Page;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.CrudRepository;

import java.awt.print.Pageable;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TaskRepository extends JpaRepository<Task, UUID> {
    List<Task> findAllByDeletedFalseOrderByCreatedAtDesc();
    Optional<Task> findByIdAndDeletedFalse(UUID id);
    Page<Task> findAllByDeletedFalse(org.springframework.data.domain.Pageable pageable);
}

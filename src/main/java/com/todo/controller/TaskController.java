package com.todo.controller;

import com.todo.entity.Task;
import com.todo.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/tasks")
@RequiredArgsConstructor
public class TaskController {

    private final TaskRepository repo;

    // Insert a mock task
    @PostMapping({"/mock", "/mock/"})
    public Task insertMock() {
        Task t = Task.builder()
                .taskName("Mock Task")
                .taskDesc("This is a mock task inserted for testing.")
                .completed(false)
                .deleted(false)
                .createdAt(Instant.now())
                .build();

        Task saved = repo.save(t);
        log.info("[TaskController] Inserted: {}", saved);
        return saved;
    }

    // Get all tasks
    @GetMapping({"", "/"})
    public List<Task> all() {
        List<Task> list = repo.findAll();
        log.info("[TaskController] Read {} tasks", list.size());
        return list;
    }
}

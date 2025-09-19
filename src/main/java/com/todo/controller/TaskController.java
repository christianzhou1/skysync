package com.todo.controller;

import com.todo.entity.Task;
import com.todo.repository.TaskRepository;
import com.todo.web.dto.CreateTaskRequest;
import com.todo.web.dto.UpdateTaskRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/tasks")
@RequiredArgsConstructor
public class TaskController {

    private final TaskRepository repo;

    // LIST (only non-deleted)
    @GetMapping
    public List<Task> list() {
        return repo.findAllByDeletedFalseOrderByCreatedAtDesc();
    }

    // GET by id (404 if deleted or not found)
    @GetMapping("/{id}")
    public ResponseEntity<Task> get(@PathVariable UUID id) {
        return repo.findByIdAndDeletedFalse(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    // CREATE
    @PostMapping
    public ResponseEntity<Task> create(@Validated @RequestBody CreateTaskRequest req) {
        Task t = new Task();
        t.setTaskName(req.getTaskName());
        t.setTaskDesc(req.getTaskDesc());
        t.setCompleted(false);
        t.setDeleted(false);
        t.setCreatedAt(Instant.now());

        Task saved = repo.save(t);

        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(saved.getId())
                .toUri();

        return ResponseEntity.created(location).body(saved);
    }

    // UPDATE (idempotent PUT; only apply non-null fields)
    @PutMapping("/{id}")
    public Optional<ResponseEntity<Task>> update(@PathVariable UUID id, @Validated @RequestBody UpdateTaskRequest req) {
        return Optional.of(repo.findByIdAndDeletedFalse(id)
                .map(existing -> {
                    if (req.getTaskName() != null) existing.setTaskName(req.getTaskName());
                    if (req.getTaskDesc() != null) existing.setTaskDesc(req.getTaskDesc());
                    if (req.getCompleted() != null) existing.setCompleted(req.getCompleted());

                    Task saved = repo.save(existing);
                    return ResponseEntity.ok(saved);
                })
                .orElseGet(() -> ResponseEntity.notFound().build()));
    }


    // SOFT DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<Object> delete(@PathVariable UUID id) {
        return repo.findByIdAndDeletedFalse(id)
                .map(existing -> {
                    existing.setDeleted(true);
                    repo.save(existing);
                    return ResponseEntity.noContent().build();
                })
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

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

//    // Get all tasks
//    @GetMapping({"", "/"})
//    public List<Task> all() {
//        List<Task> list = repo.findAll();
//        log.info("[TaskController] Read {} tasks", list.size());
//        return list;
//    }
}

package com.todo.controller;

import com.todo.entity.Task;
import com.todo.service.TaskService;
import com.todo.web.dto.CreateTaskRequest;
import com.todo.web.dto.UpdateTaskRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.function.Function;

@Slf4j
@RestController
@RequestMapping("/tasks")
@RequiredArgsConstructor
public class TaskController {

    public final TaskService taskService;

    // Paged LIST
    @GetMapping
    public ResponseEntity<List<Task>> listTasks(
            // default request parameters
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt,desc") String sort
    ) {
        // call the service to fetch Page<Task> according to parameters
        Page<Task> result = taskService.listTasks(page, size, sort);

        // build HTTP headers for pagination metadata
        HttpHeaders headers = new HttpHeaders();

        // add total number of available tasks
        headers.add("X-Total-Count", String.valueOf(result.getTotalElements()));

        // base URI of current request e.g. http://localhost8080/api/tasks
        String base = ServletUriComponentsBuilder.fromCurrentRequest().build().toUriString();

        // collect pagination navigation links in RFC 5988 format
        List<String> links = new ArrayList<>();

        // helper function to build a URI for a given page index
        Function<Integer, String> mk = p -> UriComponentsBuilder.fromUriString(base)
                .replaceQueryParam("page", p) // update page number
                .replaceQueryParam("size", result.getSize()) // keep current size
                .replaceQueryParam("sort", sort) // keep sort order
                .toUriString();

        // "first" link -> always page 0
        links.add("<" + mk.apply(0) + ">; rel=\"next\"");

        // "prev" link -> only if there is a previous page
        if (result.hasPrevious())
            links.add("<" + mk.apply(result.getNumber() - 1) + ">; rel=\"previous\"");

        // "next" link -> only if there is a next page
        if (result.hasNext())
            links.add("<" + mk.apply(result.getNumber()) + 1 + ">; rel=\"last\"");

        // combine all links into a single link header
        headers.add(HttpHeaders.LINK, String.join(",", links));

        // return 200 OK with pagination headers (X-Total-Count, Link) and current page content in body (List<Tasks>)
        return ResponseEntity.ok().headers(headers).body(result.getContent());


    }

    // GET by id (404 if deleted or not found)
    @GetMapping("/{id}")
    public Task getTaskById(@PathVariable UUID id) {
        return taskService.getTaskById(id);
    }

    // CREATE
    @PostMapping
    public ResponseEntity<Task> createTask(@Validated @RequestBody CreateTaskRequest req) {
        Task saved = taskService.createTask(req.getTaskName(), req.getTaskDesc());

        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(saved.getId())
                .toUri();

        return ResponseEntity.created(location).body(saved);
    }

    // UPDATE (idempotent PUT; only apply non-null fields)
    @PutMapping("/{id}")
    public Task updateTask(@PathVariable UUID id, @Validated @RequestBody UpdateTaskRequest req) {
        return taskService.updateTask(id, req.getTaskName(), req.getTaskDesc(), req.getCompleted());
    }

    // PATCH completion: /tasks/{id}/complete?value=true|false
    @PatchMapping("/{id}/complete")
    public Task setCompleted(@PathVariable UUID id, @RequestParam("value") boolean value) {
        return taskService.setCompleted(id, value);
    }


    // SOFT DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTask(@PathVariable UUID id) {
        taskService.deleteTask(id);
        return ResponseEntity.noContent().build();
    }

    // Insert a mock task
    @PostMapping({"/mock", "/mock/"})
    public Task insertMock() {
        return taskService.insertMock();
    }

//    // Get all tasks
//    @GetMapping({"", "/"})
//    public List<Task> all() {
//        List<Task> list = repo.findAll();
//        log.info("[TaskController] Read {} tasks", list.size());
//        return list;
//    }
}

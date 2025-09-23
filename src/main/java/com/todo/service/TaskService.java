package com.todo.service;

import com.todo.api.dto.TaskDetailInfo;
import com.todo.entity.Task;
import org.springframework.data.domain.Page;

import java.util.List;
import java.util.UUID;

public interface TaskService {


    TaskDetailInfo getTaskDetail(UUID id);

    // CRUD operations

    Task createTask(String title, String description);

    Task getTaskById(UUID id);

    List<Task> listTasks();
    Page<Task> listTasks(int page, int size, String sort);

    void deleteTask(UUID id);

    Task updateTask(UUID id, String title, String description, Boolean isComplete);

    Task setCompleted(UUID id, Boolean isComplete);

    Task insertMock();

    List<Task> listAllTasks();
//    Page<Task> listAllTasks(int page, int size, String sort);

    List<TaskDetailInfo> listAllTaskDetails();
    // Page<TaskDetailInfo> listAllTaskDetails(int page, int size, String sort);
}

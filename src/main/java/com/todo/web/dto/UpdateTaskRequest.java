package com.todo.web.dto;

import lombok.Data;

@Data
public class UpdateTaskRequest {
    private String taskName;
    private String taskDesc;
    private Boolean completed;
}

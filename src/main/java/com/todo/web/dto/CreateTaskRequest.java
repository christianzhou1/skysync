package com.todo.web.dto;

import lombok.Data;
import lombok.NonNull;

@Data
public class CreateTaskRequest {
    @NonNull
    private String taskName;

    private String taskDesc;
}

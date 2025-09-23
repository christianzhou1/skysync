package com.todo.api.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;
import java.util.UUID;


@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class TaskDetailInfo {
    // base fields
    private UUID id;
    private String title;
    private String description;
    private Instant createdAt;
    private Instant dueDate;
    private boolean isCompleted;
    private boolean isDeleted;

    // Enriched fields examples
    private boolean overdue; // computed from dueDate + completed
    private Long daysUntilDue; // computed helper for UX

    // related data examples
    private List<String> categories; // potential LabelRepository
    private List<CommentInfo> comments;
    private List<AttachmentInfo> attachments;


    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CommentInfo {
        private UUID id;
        private String body;
        private Instant createdAt;
        private String author;
    }

}

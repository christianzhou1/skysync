package com.todo.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UuidGenerator;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "task") // explicit table name
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Task {

    @Id
    @GeneratedValue
    @UuidGenerator
    private UUID id;

    @Column(name = "task_name", nullable = false, length = 255)
    private String taskName;

    @Column(name = "task_desc")
    private String taskDesc;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "is_completed", nullable = false)
    private boolean completed;

    @Column(name = "is_delete", nullable = false)
    private boolean deleted;
}

package com.todo.service.impl;

import com.todo.api.dto.AttachmentInfo;
import com.todo.api.mapper.AttachmentMapper;
import com.todo.entity.Attachment;
import com.todo.entity.Task;
import com.todo.repository.AttachmentRepository;
import com.todo.repository.TaskRepository;
import com.todo.service.AttachmentService;
import com.todo.service.TaskService;
import com.todo.storage.BlobStorage;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.hibernate.service.spi.ServiceException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@Slf4j
@RequiredArgsConstructor
@Transactional
public class AttachmentServiceImpl implements AttachmentService {

    private final AttachmentRepository attachmentRepo;
    private final TaskRepository taskRepo;
    private final BlobStorage blobStorage;

    @Override
    public AttachmentInfo uploadUnlinked(MultipartFile file) throws IOException {
        try {
            var stored = blobStorage.store(file.getInputStream(),
                    file.getOriginalFilename(), file.getContentType(), file.getSize());

            Attachment a = Attachment.builder()
                    .filename(file.getOriginalFilename() != null ? file.getOriginalFilename() : "file")
                    .contentType(stored.getContentType())
                    .sizeBytes(stored.getSize())
                    .checksumSha256(stored.getChecksumSha256())
                    .storagePath(stored.getKey())
                    .createdAt(Instant.now())
                    .updatedAt(Instant.now())
                    .build();

            a = attachmentRepo.save(a);
            return AttachmentMapper.toInfo(a);
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            log.error("uploadUnlinked failed", e);
            throw new ServiceException("Uncaught error");
        }
    }


    @Override
    public AttachmentInfo uploadAndAttach(UUID taskId, MultipartFile file) throws IOException {
        try {
            Task task = taskRepo.findById(taskId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Task not found"));

            var stored = blobStorage.store(file.getInputStream(),
                    file.getOriginalFilename(), file.getContentType(), file.getSize());

            Attachment a = Attachment.builder()
                    .task(task)
                    .filename(file.getOriginalFilename() != null ? file.getOriginalFilename() : "file")
                    .contentType(stored.getContentType())
                    .sizeBytes(stored.getSize())
                    .checksumSha256(stored.getChecksumSha256())
                    .storagePath(stored.getKey())
                    .createdAt(Instant.now())
                    .updatedAt(Instant.now())
                    .build();
            a = attachmentRepo.save(a);
            return AttachmentMapper.toInfo(a);
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            log.error("uploadAndAttach failed (taskId={})", taskId, e);
            throw new ServiceException("Unexpected error");
        }
    }


    @Override
    @Transactional(Transactional.TxType.SUPPORTS)
    public List<AttachmentInfo> listByTask(UUID taskId) {
        return attachmentRepo.findByTask_Id(taskId).stream()
                .map(AttachmentMapper::toInfo)
                .toList();
    }


    @Override
    public AttachmentInfo attach(UUID attachmentId, UUID taskId) {
        try {
            Attachment a = attachmentRepo.findById(attachmentId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Attachment not found"));

            Task t = taskRepo.findById(taskId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Task not found"));

            a.setTask(t);
            return AttachmentMapper.toInfo(a);
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            log.error("attach failed (attachmentId={}, taskId={})", attachmentId, taskId, e);
            throw new ServiceException("Unexpected error");
        }
    }


    @Override
    public AttachmentInfo detach(UUID attachmentId) {
        try {
            Attachment a = attachmentRepo.findById(attachmentId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Attachment not found"));
            a.setTask(null);
            return AttachmentMapper.toInfo(a);
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            log.error("detach failed (attachmentId={})", attachmentId, e);
            throw new ServiceException("Unexpected error");
        }
    }


    @Override
    public void delete(UUID attachmentId) {
        try {
            Attachment a = attachmentRepo.findById(attachmentId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Attachment not found"));
            try {
                blobStorage.delete(a.getStoragePath());
            } catch (IOException io) {
                log.warn("Failed to delete underlying blob for {}", attachmentId, io);
            }
            attachmentRepo.delete(a);
        } catch (ResponseStatusException e) {
            throw e;
        }  catch (Exception e) {
            log.error("delete failed (attachmentId={})", attachmentId, e);
            throw new ServiceException("Unexpected error");
        }
    }


    @Override
    @Transactional(Transactional.TxType.SUPPORTS)
    public byte[] loadBytes(UUID attachmentId) throws IOException {
        Attachment a = attachmentRepo.findById(attachmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Attachment not found"));
        return blobStorage.load(a.getStoragePath());
    }

    @Override
    @Transactional(Transactional.TxType.SUPPORTS)
    public AttachmentInfo getInfo(UUID attachmentId) {
        Attachment a = attachmentRepo.findById(attachmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Attachment not found"));
        return AttachmentMapper.toInfo(a);
    }
}

package com.todo.service;

import com.todo.api.dto.AttachmentInfo;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

public interface AttachmentService {
    AttachmentInfo uploadUnlinked(MultipartFile file) throws IOException;
    AttachmentInfo uploadAndAttach(UUID taskId, MultipartFile file) throws IOException;

    List<AttachmentInfo> listByTask(UUID taskId);

    AttachmentInfo attach(UUID attachmentId, UUID taskId);
    AttachmentInfo detach(UUID attachmentId);

    void delete(UUID attachmentId);

    byte[] loadBytes(UUID attachmentId) throws IOException;

    AttachmentInfo getInfo(UUID attachmentId);
}

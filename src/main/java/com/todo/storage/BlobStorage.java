package com.todo.storage;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.io.IOException;
import java.io.InputStream;

public interface BlobStorage {
    @Data
    @AllArgsConstructor
    public class StoredObject {
        String key;
        String contentType;
        long size;
        String checksumSha256;
    }

    StoredObject store(InputStream in, String originalName, String contentType, long size) throws IOException;

    byte[] load(String key) throws IOException;
    void delete(String key) throws IOException;

}

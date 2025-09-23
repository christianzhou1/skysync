package com.todo.config;

import com.todo.storage.BlobStorage;
import com.todo.storage.BlobStorageImpl.LocalBlobStorageImpl;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class StorageConfig {
    @Bean
    public BlobStorage blobStorage(LocalBlobStorageImpl local) {
        // default = local storage
        return local;
    }

}


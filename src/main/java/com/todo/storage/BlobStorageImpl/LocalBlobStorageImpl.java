package com.todo.storage.BlobStorageImpl;

import com.todo.storage.BlobStorage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.UUID;

@Component
@RequiredArgsConstructor
@Slf4j
@ConditionalOnProperty(name = "app.storage.type", havingValue = "local")
public class LocalBlobStorageImpl implements BlobStorage {
    @Value("${app.storage.root-dir:./uploads}")
    private String rootDir;

    private Path root() throws IOException {
        Path p = Paths.get(rootDir).toAbsolutePath().normalize();
        Files.createDirectories(p);
        return p;
    }

    private static String sha256(byte[] bytes) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(md.digest(bytes));
        } catch (Exception e) {
            throw new RuntimeException("Unable to compute checksum", e);
        }
    }

    @Override
    public StoredObject store(InputStream in, String originalName, String contentType, long size) throws IOException {

        byte[] bytes = in.readAllBytes();

        String ext = (originalName != null && originalName.contains("."))
                ? originalName.substring(originalName.lastIndexOf(".") + 1)
                :"bin";

        String fname = UUID.randomUUID() + (ext.isEmpty() ? "" : ("." + ext));

        Path dest = root().resolve(fname);

        Files.write(dest, bytes, StandardOpenOption.CREATE_NEW);

        String ct = (contentType != null ? contentType : MediaType.APPLICATION_OCTET_STREAM_VALUE);

        return new StoredObject(dest.toString(), ct, bytes.length, sha256(bytes));
    }

    @Override
    public byte[] load(String key) throws IOException {
        return Files.readAllBytes(Paths.get(key));
    }

    @Override
    public void delete(String key) throws IOException {
        Files.deleteIfExists(Paths.get(key));
    }
}

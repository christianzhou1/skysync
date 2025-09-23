CREATE TABLE attachment (
                            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                            task_id UUID NULL REFERENCES task(id) ON DELETE SET NULL,
                            filename VARCHAR(255) NOT NULL,
                            content_type VARCHAR(150) NOT NULL,
                            size_bytes BIGINT NOT NULL,
                            checksum_sha256 CHAR(64) NOT NULL,
                            storage_path TEXT NOT NULL,
                            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_attachment_task_id ON attachment(task_id);
CREATE INDEX idx_attachment_created_at ON attachment(created_at);

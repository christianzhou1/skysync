-- Optional: let Postgres generate UUIDs (choose one extension if you want DB-side UUIDs)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";  -- for uuid_generate_v4()
CREATE EXTENSION IF NOT EXISTS pgcrypto;     -- for gen_random_uuid()

CREATE TABLE task (
                      id           uuid PRIMARY KEY,                          -- or: uuid DEFAULT gen_random_uuid() PRIMARY KEY
                      task_name    varchar(255) NOT NULL,
                      task_desc    text,
                      created_at   timestamptz NOT NULL DEFAULT now(),
                      is_completed boolean NOT NULL DEFAULT false,
                      is_delete    boolean NOT NULL DEFAULT false
);

-- Helpful indexes for common queries:
CREATE INDEX IF NOT EXISTS idx_task_created_at ON task (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_task_is_delete   ON task (is_delete);
CREATE INDEX IF NOT EXISTS idx_task_is_completed ON task (is_completed);

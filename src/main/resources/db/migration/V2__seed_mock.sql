-- If using DB-generated UUIDs, omit the id column here.
INSERT INTO task (id, task_name, task_desc, is_completed, is_delete)
VALUES (gen_random_uuid(), 'First task', 'Hello, world', false, false);

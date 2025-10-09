-- Add display_order column for manual task ordering
ALTER TABLE task ADD COLUMN display_order INTEGER;

-- Set initial display_order for ROOT tasks (created_at DESC - newest first)
WITH ordered_root_tasks AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (
      ORDER BY created_at DESC
    ) as new_order
  FROM task
  WHERE is_deleted = false
    AND parent_task_id IS NULL
)
UPDATE task
SET display_order = ordered_root_tasks.new_order
FROM ordered_root_tasks
WHERE task.id = ordered_root_tasks.id;

-- Set initial display_order for SUBTASKS (created_at ASC - oldest first)
WITH ordered_subtasks AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (
      PARTITION BY parent_task_id
      ORDER BY created_at ASC
    ) as new_order
  FROM task
  WHERE is_deleted = false
    AND parent_task_id IS NOT NULL
)
UPDATE task
SET display_order = ordered_subtasks.new_order
FROM ordered_subtasks
WHERE task.id = ordered_subtasks.id;

-- Add index for efficient ordering queries
CREATE INDEX idx_task_display_order ON task(parent_task_id, display_order);

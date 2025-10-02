-- Revert from many-to-many back to one-to-many relationship
-- Step 1: Add back the task_id column to attachment table
ALTER TABLE attachment ADD COLUMN task_id UUID;

-- Step 2: Migrate data from junction table back to attachment.task_id
-- (This assumes each attachment should be linked to the first task it was associated with)
UPDATE attachment 
SET task_id = (
    SELECT task_id 
    FROM task_attachment 
    WHERE task_attachment.attachment_id = attachment.id 
    LIMIT 1
);

-- Step 3: Add foreign key constraint
ALTER TABLE attachment ADD CONSTRAINT fk_attachment_task_id FOREIGN KEY (task_id) REFERENCES task(id) ON DELETE SET NULL;

-- Step 4: Create index for performance
CREATE INDEX idx_attachment_task_id ON attachment(task_id);

-- Step 5: Drop the junction table
DROP TABLE task_attachment;
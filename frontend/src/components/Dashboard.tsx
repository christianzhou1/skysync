import React, { useState } from "react";
import TaskList from "./TaskList.tsx";
import type { Task } from "./TaskList.tsx";
import TaskDetail from "./TaskDetail.tsx";
import { ResizeHandle } from "./ResizeHandle.tsx";
import { Panel, PanelGroup } from "react-resizable-panels";
import { Box } from "@mui/material";
import AttachmentList from "./AttachmentList.tsx";

const Dashboard: React.FC = () => {
  const [selectedTask, setSelectedTask] = useState<Task | null>(null);

  const handleTaskSelect = (task: Task) => {
    setSelectedTask(task);
  };

  return (
    <Box
      sx={{
        height: "100%",
        border: 0,
        borderRadius: 2,
        overflow: "hidden",
      }}
    >
      <PanelGroup direction="horizontal">
        <Panel defaultSize={50} minSize={20}>
          <TaskList
            onTaskSelect={handleTaskSelect}
            selectedTaskId={selectedTask?.id}
          />
        </Panel>
        <ResizeHandle />
        <Panel>
          <PanelGroup direction="vertical">
            <Panel minSize={30}>
              <TaskDetail selectedTask={selectedTask} />
            </Panel>
            <ResizeHandle />
            <Panel minSize={30}>
              <AttachmentList />
            </Panel>
          </PanelGroup>
        </Panel>
      </PanelGroup>
    </Box>
  );
};

export default Dashboard;

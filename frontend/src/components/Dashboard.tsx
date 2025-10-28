import React, { useState } from "react";
import TaskList from "./TaskList.tsx";
import type { Task } from "./TaskList.tsx";
import TaskDetail from "./TaskDetail.tsx";
import { ResizeHandle } from "./ResizeHandle.tsx";
import { Panel, PanelGroup } from "react-resizable-panels";
import { Box, Tabs, Tab, useMediaQuery, useTheme } from "@mui/material";
import AttachmentList from "./AttachmentList.tsx";

const Dashboard: React.FC = () => {
  const [selectedTask, setSelectedTask] = useState<Task | null>(null);
  const [attachmentFilterTask, setAttachmentFilterTask] = useState<Task | null>(
    null
  );
  const [activeTab, setActiveTab] = useState(0);

  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down("lg"));

  const handleTaskSelect = (task: Task) => {
    // If clicking the same task, deselect it
    if (selectedTask?.id === task.id) {
      setSelectedTask(null);
      setAttachmentFilterTask(null);
    } else {
      setSelectedTask(task);
      setAttachmentFilterTask(task); // Also set the attachment filter when a task is selected
    }
  };

  const handleClearAttachmentFilter = () => {
    setAttachmentFilterTask(null); // Only clear the attachment filter, not the selected task
  };

  const handleTaskDeselect = () => {
    setSelectedTask(null);
    setAttachmentFilterTask(null);
  };

  const handleTabChange = (_event: React.SyntheticEvent, newValue: number) => {
    setActiveTab(newValue);
  };

  if (isMobile) {
    return (
      <Box
        sx={{
          height: "100%",
          display: "flex",
          flexDirection: "column",
          overflow: "hidden",
        }}
      >
        <Tabs
          value={activeTab}
          onChange={handleTabChange}
          variant="fullWidth"
          sx={{
            borderBottom: 1,
            borderColor: "divider",
            backgroundColor: "background.paper",
          }}
        >
          <Tab label="Tasks" />
          <Tab label="Detail" />
          <Tab label="Attachments" />
        </Tabs>

        <Box sx={{ flex: 1, overflow: "hidden" }}>
          {activeTab === 0 && (
            <TaskList
              onTaskSelect={handleTaskSelect}
              onTaskDeselect={handleTaskDeselect}
              selectedTaskId={selectedTask?.id}
            />
          )}
          {activeTab === 1 && <TaskDetail selectedTask={selectedTask} />}
          {activeTab === 2 && (
            <AttachmentList
              selectedTask={attachmentFilterTask}
              onClearFilter={handleClearAttachmentFilter}
            />
          )}
        </Box>
      </Box>
    );
  }

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
            onTaskDeselect={handleTaskDeselect}
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
              <AttachmentList
                selectedTask={attachmentFilterTask}
                onClearFilter={handleClearAttachmentFilter}
              />
            </Panel>
          </PanelGroup>
        </Panel>
      </PanelGroup>
    </Box>
  );
};

export default Dashboard;

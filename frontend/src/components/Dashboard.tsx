import React from "react";
import TaskList from "./TaskList.tsx";
import TaskDetail from "./TaskDetail.tsx";
import { ResizeHandle } from "./ResizeHandle.tsx";
import { Panel, PanelGroup } from "react-resizable-panels";

const Dashboard: React.FC = () => {
  return (
    <>
      <PanelGroup direction="horizontal">
        <Panel defaultSize={50} minSize={20}>
          <TaskList />
        </Panel>
        <ResizeHandle />
        <Panel minSize={30}>
          <TaskDetail />
        </Panel>
      </PanelGroup>
    </>
  );
};

export default Dashboard;

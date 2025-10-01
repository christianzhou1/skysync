import React, { useState, useEffect } from "react";
import { taskService, authService } from "../services";

interface Task {
  id: string;
  title: string;
  description: string;
  isCompleted: boolean;
  createdAt: string;
  updatedAt: string;
}

const TaskList: React.FC = () => {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchTasks = async () => {
    setLoading(true);
    setError(null);

    try {
      const userId = authService.getUserId();
      if (!userId) {
        setError("User not authenticated");
        return;
      }

      const response = await taskService.getAllTasks(userId);

      if (response.code === 200 && response.data) {
        setTasks(response.data);
      } else {
        setError(response.msg);
      }
    } catch (err) {
      setError("Failed to fetch tasks");
    } finally {
      setLoading(false);
    }
  };

  const toggleTaskCompletion = async (
    taskId: string,
    currentStatus: boolean
  ) => {
    try {
      const userId = authService.getUserId();
      if (!userId) return;

      const response = await taskService.setTaskCompleted(
        taskId,
        !currentStatus,
        userId
      );

      if (response.code === 200) {
        // Update local state
        setTasks(
          tasks.map((task) =>
            task.id === taskId ? { ...task, isCompleted: !currentStatus } : task
          )
        );
      } else {
        setError(response.msg);
      }
    } catch (err) {
      setError("Failed to update task");
    }
  };

  const deleteTask = async (taskId: string) => {
    try {
      const userId = authService.getUserId();
      if (!userId) return;

      const response = await taskService.deleteTask(taskId, userId);

      if (response.code === 200) {
        // Remove from local state
        setTasks(tasks.filter((task) => task.id !== taskId));
      } else {
        setError(response.msg);
      }
    } catch (err) {
      setError("Failed to delete task");
    }
  };

  useEffect(() => {
    fetchTasks();
  }, []);

  if (loading) {
    return (
      <div className="text-center py-8 text-lg text-gray-600">
        Loading tasks...
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-600 text-white p-4 rounded text-center">
        <p>Error: {error}</p>
        <button
          onClick={fetchTasks}
          className="bg-white text-red-600 border-0 px-4 py-2 rounded cursor-pointer mt-2"
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <div className="bg-white p-8 rounded-lg shadow-lg">
      <h2 className="mt-0 text-slate-800 flex justify-between items-center">
        My Tasks
        <button
          onClick={fetchTasks}
          className="bg-blue-600 text-white border-0 px-4 py-2 rounded cursor-pointer text-sm hover:bg-blue-700"
        >
          Refresh
        </button>
      </h2>

      {tasks.length === 0 ? (
        <p className="text-gray-600">No tasks found. Create your first task!</p>
      ) : (
        <ul className="list-none p-0 my-4">
          {tasks.map((task) => (
            <li
              key={task.id}
              className={`border border-gray-200 rounded p-4 mb-4 flex justify-between items-start ${
                task.isCompleted ? "bg-gray-50 opacity-70" : ""
              }`}
            >
              <div className="flex-1">
                <h3 className="m-0 mb-2 text-slate-800">{task.title}</h3>
                <p className="m-0 mb-2 text-gray-600">{task.description}</p>
                <small className="text-gray-500 text-xs">
                  Created: {new Date(task.createdAt).toLocaleDateString()}
                </small>
              </div>
              <div className="flex gap-2 flex-shrink-0">
                <button
                  onClick={() =>
                    toggleTaskCompletion(task.id, task.isCompleted)
                  }
                  className={`text-white border-0 px-4 py-2 rounded cursor-pointer text-sm ${
                    task.isCompleted
                      ? "bg-yellow-600 hover:bg-yellow-700"
                      : "bg-green-600 hover:bg-green-700"
                  }`}
                >
                  {task.isCompleted ? "Mark Incomplete" : "Mark Complete"}
                </button>
                <button
                  onClick={() => deleteTask(task.id)}
                  className="bg-red-600 text-white border-0 px-4 py-2 rounded cursor-pointer text-sm hover:bg-red-700"
                >
                  Delete
                </button>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default TaskList;

import React, { useState, useEffect } from "react";
import { authService } from "./services";
import LoginForm from "./components/LoginForm";
import TaskList from "./components/TaskList";
import "./App.css";

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is already authenticated
    const checkAuth = () => {
      const authenticated = authService.isAuthenticated();
      setIsAuthenticated(authenticated);
      setLoading(false);
    };

    checkAuth();
  }, []);

  const handleLoginSuccess = () => {
    setIsAuthenticated(true);
  };

  const handleLogout = async () => {
    await authService.logout();
    setIsAuthenticated(false);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="text-center py-8 text-lg text-gray-600">Loading...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-slate-800 text-white px-8 py-4 flex justify-between items-center shadow-md">
        <h1 className="m-0 text-2xl">Todo App</h1>
        {isAuthenticated && (
          <button
            onClick={handleLogout}
            className="bg-red-600 text-white border-0 px-4 py-2 rounded cursor-pointer text-sm hover:bg-red-700"
          >
            Logout
          </button>
        )}
      </header>

      <main className="max-w-4xl mx-auto my-8 px-4">
        {!isAuthenticated ? (
          <LoginForm onLoginSuccess={handleLoginSuccess} />
        ) : (
          <TaskList />
        )}
      </main>
    </div>
  );
}

export default App;

import React, { useState, useEffect } from "react";
import { Paper, Typography, Box } from "@mui/material";

const TaskDetail: React.FC = () => {
  return (
    <Paper elevation={3} sx={{ p: 3, height: "100%", borderRadius: 2 }}>
      <Typography variant="h5" component="h2" gutterBottom>
        Task Detail
      </Typography>
      <Box sx={{ mt: 2 }}>
        <Typography variant="body1" color="text.secondary">
          Select a task from the list to view its details here.
        </Typography>
      </Box>
    </Paper>
  );
};

export default TaskDetail;

import React, {useState, useEffect} from "react";

import {attachmentService, authService} from "../services";
import {Alert, Box, Button, CircularProgress, Paper, Typography} from "@mui/material";

export interface Attachment {
  id: string;
  filename: string;
  contentType: string;
  createdAt: string;
  updatedAt: string;
}

const AttachmentList: React.FC = () => {
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [attachments, setAttachments] = useState<Attachment[]>([]);

  const fetchAttachments = async () => {
    setLoading(true);
    setError(null);

    try {
      const userId = authService.getUserId();
      if (!userId) {
        setError("User not authenticated");
        return;
      }

      const response = await attachmentService.getUserAttachments(userId);

      if (response.code === 200 && response.data) {
        setAttachments(response.data);
      } else {
        setError(response.msg);
      }
    } catch {
      setError("Failed to fetch tasks");
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        minHeight="200px"
      >
        <CircularProgress />
      </Box>
    );
  }

  if (error) {
    return (
      <Alert
        severity="error"
        action={
          <Button onClick={fetchAttachments} color="inherit" size="small">
            Retry
          </Button>
        }
      >
        Error: {error}
      </Alert>
    );
  }

  return (
    <Paper
      elevation={3}
      sx={{
        p: 3,
        borderRadius: 2,
        height: "100%",
        display: "flex",
        flexDirection: "column",
        overflow: "hidden",
      }}
    >
      {attachments.length === 0 ? (
        <Box
          sx={{
            flex: 1,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <Typography variant="body1" color="text.secondary" textAlign="center">
            No attachments yet
          </Typography>
        </Box>
    ) : (
        attachments.map((attachment) =>
          <Box>
            attachment.filename
          </Box>
        )
      )}
    </Paper>
  );
};

export default AttachmentList;
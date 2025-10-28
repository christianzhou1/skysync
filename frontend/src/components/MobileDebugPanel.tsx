import React, { useState, useEffect } from "react";
import {
  Box,
  Button,
  Typography,
  Paper,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Chip,
  Alert,
} from "@mui/material";
import {
  ExpandMore,
  BugReport,
  Refresh,
  Upload,
  FileUpload,
} from "@mui/icons-material";
import { envConfig } from "../config/env";
import { attachmentService, authService } from "../services";

interface DebugInfo {
  userAgent: string;
  apiBaseUrl: string;
  isMobile: boolean;
  localStorage: Record<string, string>;
  timestamp: string;
  networkStatus: string;
}

interface UploadDebugInfo {
  selectedFile: File | null;
  uploadProgress: number;
  uploadStatus: "idle" | "uploading" | "success" | "error";
  lastError: string | null;
  uploadLogs: string[];
}

const MobileDebugPanel: React.FC = () => {
  const [debugInfo, setDebugInfo] = useState<DebugInfo | null>(null);
  const [isVisible, setIsVisible] = useState(false);
  const [uploadDebugInfo, setUploadDebugInfo] = useState<UploadDebugInfo>({
    selectedFile: null,
    uploadProgress: 0,
    uploadStatus: "idle",
    lastError: null,
    uploadLogs: [],
  });

  const updateDebugInfo = () => {
    const info: DebugInfo = {
      userAgent: navigator.userAgent,
      apiBaseUrl: envConfig.apiBaseUrl,
      isMobile:
        /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
          navigator.userAgent
        ),
      localStorage: {
        authToken: localStorage.getItem("authToken") ? "Present" : "Missing",
        userId: localStorage.getItem("userId") || "Missing",
        userInfo: localStorage.getItem("userInfo") ? "Present" : "Missing",
      },
      timestamp: new Date().toISOString(),
      networkStatus: navigator.onLine ? "Online" : "Offline",
    };
    setDebugInfo(info);
  };

  useEffect(() => {
    updateDebugInfo();
  }, []);

  const testApiConnection = async () => {
    try {
      console.log("🧪 Testing API connection...");
      const response = await fetch(`${envConfig.apiBaseUrl}/hello`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });

      const data = await response.text();
      console.log("✅ API test successful:", { status: response.status, data });
      alert(`API Test: ${response.status} - ${data}`);
    } catch (error) {
      console.error("❌ API test failed:", error);
      alert(`API Test Failed: ${error}`);
    }
  };

  const testServerLimits = async () => {
    addUploadLog("🔍 Testing server file size limits...");

    try {
      // Test with a small file first
      const smallFile = new File(["test content"], "test.txt", {
        type: "text/plain",
      });
      addUploadLog(`📁 Test file size: ${smallFile.size} bytes`);

      const userId = authService.getUserId();
      if (!userId) {
        addUploadLog("❌ No user ID found");
        return;
      }

      addUploadLog("📤 Testing with small file...");
      const response = await attachmentService.uploadFile(smallFile, userId);

      if (response.code === 200) {
        addUploadLog("✅ Small file upload successful");
        addUploadLog(
          "💡 Server accepts small files - checking actual limits..."
        );

        // Now test with progressively larger files to find the actual limit
        await testProgressiveFileSizes(userId);
      } else {
        addUploadLog(
          `❌ Small file upload failed: ${response.code} - ${response.msg}`
        );
      }
    } catch (error) {
      addUploadLog(`❌ Server limits test error: ${error}`);
    }
  };

  const testRequestSizeAnalysis = async () => {
    addUploadLog("🔍 Analyzing request size vs file size...");

    try {
      const userId = authService.getUserId();
      if (!userId) {
        addUploadLog("❌ No user ID found");
        return;
      }

      // Create a 1MB test file
      const content = new Array(1024 * 1024).fill("a").join("");
      const testFile = new File([content], "test_1mb.txt", {
        type: "text/plain",
      });

      addUploadLog(
        `📁 Test file size: ${testFile.size} bytes (${(
          testFile.size /
          (1024 * 1024)
        ).toFixed(2)}MB)`
      );

      // Create FormData to see actual request size
      const formData = new FormData();
      formData.append("file", testFile);

      addUploadLog("📊 FormData created - analyzing request structure...");
      const formDataEntry = formData.get("file");
      if (formDataEntry instanceof File) {
        addUploadLog(`📊 File in FormData: ${formDataEntry.name}`);
      } else {
        addUploadLog(`📊 FormData entry: ${typeof formDataEntry}`);
      }

      // Test the actual upload
      addUploadLog("📤 Testing 1MB file upload...");
      const response = await attachmentService.uploadFile(testFile, userId);

      if (response.code === 200) {
        addUploadLog("✅ 1MB upload successful");

        // Now test with a larger file
        const content2MB = new Array(2 * 1024 * 1024).fill("a").join("");
        const testFile2MB = new File([content2MB], "test_2mb.txt", {
          type: "text/plain",
        });

        addUploadLog(
          `📁 Testing 2MB file: ${testFile2MB.size} bytes (${(
            testFile2MB.size /
            (1024 * 1024)
          ).toFixed(2)}MB)`
        );

        const response2MB = await attachmentService.uploadFile(
          testFile2MB,
          userId
        );

        if (response2MB.code === 200) {
          addUploadLog("✅ 2MB upload successful");
        } else {
          addUploadLog(
            `❌ 2MB upload failed: ${response2MB.code} - ${response2MB.msg}`
          );
          addUploadLog("🚨 LIMIT FOUND: Between 1MB and 2MB");
        }
      } else {
        addUploadLog(
          `❌ 1MB upload failed: ${response.code} - ${response.msg}`
        );
        addUploadLog("🚨 LIMIT FOUND: Less than 1MB");
      }
    } catch (error) {
      addUploadLog(`❌ Request size analysis error: ${error}`);
    }
  };

  const testSmallFiles = async () => {
    addUploadLog("🔍 Testing small file sizes to find exact limit...");

    try {
      const userId = authService.getUserId();
      if (!userId) {
        addUploadLog("❌ No user ID found");
        return;
      }

      // Test very small files to find the exact breaking point
      const testSizes = [
        { size: 10 * 1024, name: "10KB" }, // 10KB
        { size: 50 * 1024, name: "50KB" }, // 50KB
        { size: 100 * 1024, name: "100KB" }, // 100KB
        { size: 500 * 1024, name: "500KB" }, // 500KB
        { size: 800 * 1024, name: "800KB" }, // 800KB
        { size: 900 * 1024, name: "900KB" }, // 900KB
        { size: 950 * 1024, name: "950KB" }, // 950KB
        { size: 990 * 1024, name: "990KB" }, // 990KB
        { size: 1024 * 1024, name: "1MB" }, // 1MB
        { size: 1025 * 1024, name: "1.001MB" }, // Just over 1MB
      ];

      for (const testSize of testSizes) {
        addUploadLog(`🧪 Testing ${testSize.name} file...`);

        const content = new Array(testSize.size).fill("a").join("");
        const testFile = new File([content], `test_${testSize.name}.txt`, {
          type: "text/plain",
        });

        addUploadLog(
          `📁 Created file: ${testFile.size} bytes (${(
            testFile.size /
            (1024 * 1024)
          ).toFixed(3)}MB)`
        );

        try {
          const response = await attachmentService.uploadFile(testFile, userId);

          if (response.code === 200) {
            addUploadLog(`✅ ${testSize.name} upload successful`);
          } else {
            addUploadLog(
              `❌ ${testSize.name} upload failed: ${response.code} - ${response.msg}`
            );
            addUploadLog(
              `🚨 EXACT LIMIT FOUND: ${testSize.name} is the breaking point`
            );
            addUploadLog(`🚨 This suggests nginx client_max_body_size limit`);
            break;
          }
        } catch (error) {
          addUploadLog(`❌ ${testSize.name} upload error: ${error}`);
          addUploadLog(
            `🚨 EXACT LIMIT FOUND: ${testSize.name} is the breaking point`
          );
          addUploadLog(`🚨 This suggests nginx client_max_body_size limit`);
          break;
        }

        // Small delay between tests
        await new Promise((resolve) => setTimeout(resolve, 200));
      }
    } catch (error) {
      addUploadLog(`❌ Small files test error: ${error}`);
    }
  };

  const testProgressiveFileSizes = async (userId: string) => {
    const testSizes = [
      { size: 100 * 1024, name: "100KB" }, // 100KB
      { size: 500 * 1024, name: "500KB" }, // 500KB
      { size: 1024 * 1024, name: "1MB" }, // 1MB
      { size: 2 * 1024 * 1024, name: "2MB" }, // 2MB
      { size: 5 * 1024 * 1024, name: "5MB" }, // 5MB
      { size: 10 * 1024 * 1024, name: "10MB" }, // 10MB
    ];

    for (const testSize of testSizes) {
      addUploadLog(`🧪 Testing ${testSize.name} file...`);

      // Create a file of the specified size
      const content = new Array(testSize.size).fill("a").join("");
      const testFile = new File([content], `test_${testSize.name}.txt`, {
        type: "text/plain",
      });

      addUploadLog(
        `📁 Created file: ${testFile.size} bytes (${(
          testFile.size /
          (1024 * 1024)
        ).toFixed(2)}MB)`
      );

      try {
        const response = await attachmentService.uploadFile(testFile, userId);

        if (response.code === 200) {
          addUploadLog(`✅ ${testSize.name} upload successful`);
        } else {
          addUploadLog(
            `❌ ${testSize.name} upload failed: ${response.code} - ${response.msg}`
          );
          addUploadLog(
            `🚨 ACTUAL LIMIT FOUND: ${testSize.name} is the breaking point`
          );
          break;
        }
      } catch (error) {
        addUploadLog(`❌ ${testSize.name} upload error: ${error}`);
        addUploadLog(
          `🚨 ACTUAL LIMIT FOUND: ${testSize.name} is the breaking point`
        );
        break;
      }

      // Small delay between tests
      await new Promise((resolve) => setTimeout(resolve, 500));
    }
  };

  const clearStorage = () => {
    localStorage.clear();
    updateDebugInfo();
    alert("Local storage cleared!");
  };

  const addUploadLog = (message: string) => {
    const timestamp = new Date().toLocaleTimeString();
    const logEntry = `[${timestamp}] ${message}`;
    setUploadDebugInfo((prev) => ({
      ...prev,
      uploadLogs: [...prev.uploadLogs.slice(-9), logEntry], // Keep last 10 logs
    }));
    console.log(`📱 Mobile Debug: ${logEntry}`);
  };

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      // Enhanced debugging for file size
      const fileSizeBytes = file.size;
      const fileSizeMB = (fileSizeBytes / (1024 * 1024)).toFixed(2);
      const maxSizeBytes = 25 * 1024 * 1024; // 25MB in bytes
      const maxSizeMB = 25;

      addUploadLog(`📁 File selected: ${file.name}`);
      addUploadLog(`📁 File size: ${fileSizeBytes} bytes`);
      addUploadLog(`📁 File size: ${fileSizeMB} MB`);
      addUploadLog(`📁 Max allowed: ${maxSizeBytes} bytes (${maxSizeMB} MB)`);
      addUploadLog(
        `📁 Size check: ${fileSizeBytes} <= ${maxSizeBytes} = ${
          fileSizeBytes <= maxSizeBytes
        }`
      );

      // Check file size (25MB limit)
      if (fileSizeBytes > maxSizeBytes) {
        addUploadLog(
          `🚨 File too large: ${fileSizeMB}MB (limit: ${maxSizeMB}MB)`
        );
        setUploadDebugInfo((prev) => ({
          ...prev,
          selectedFile: null,
          uploadStatus: "error",
          lastError: `File too large: ${fileSizeMB}MB. Maximum allowed size is ${maxSizeMB}MB.`,
        }));
        return;
      }

      addUploadLog(`✅ File size OK: ${fileSizeMB}MB <= ${maxSizeMB}MB`);
      setUploadDebugInfo((prev) => ({
        ...prev,
        selectedFile: file,
        uploadStatus: "idle",
        lastError: null,
      }));
      addUploadLog(
        `File selected: ${file.name} (${file.size} bytes, ${file.type})`
      );
    }
  };

  const testFileUpload = async () => {
    if (!uploadDebugInfo.selectedFile) {
      addUploadLog("❌ No file selected for upload test");
      return;
    }

    const userId = authService.getUserId();
    if (!userId) {
      addUploadLog("❌ No user ID found - user not authenticated");
      setUploadDebugInfo((prev) => ({
        ...prev,
        uploadStatus: "error",
        lastError: "User not authenticated",
      }));
      return;
    }

    setUploadDebugInfo((prev) => ({
      ...prev,
      uploadStatus: "uploading",
      uploadProgress: 0,
      lastError: null,
    }));

    addUploadLog(`🚀 Starting upload test for user: ${userId}`);
    addUploadLog(`📁 File: ${uploadDebugInfo.selectedFile.name}`);
    addUploadLog(`🌐 API URL: ${envConfig.apiBaseUrl}`);
    addUploadLog(`📱 User Agent: ${navigator.userAgent}`);
    addUploadLog(`🔗 Current URL: ${window.location.href}`);

    // Test network connectivity first
    try {
      addUploadLog("🔍 Testing network connectivity...");
      const connectivityTest = await fetch(`${envConfig.apiBaseUrl}/hello`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (connectivityTest.ok) {
        addUploadLog("✅ Network connectivity confirmed");
      } else {
        addUploadLog(
          `⚠️ Network test returned status: ${connectivityTest.status}`
        );
      }
    } catch (networkError) {
      addUploadLog(`❌ Network connectivity test failed: ${networkError}`);
    }

    // Test authentication
    try {
      addUploadLog("🔐 Testing authentication...");
      const authToken = localStorage.getItem("authToken");
      if (authToken) {
        addUploadLog(`✅ Auth token found (length: ${authToken.length})`);
      } else {
        addUploadLog("❌ No auth token found in localStorage");
      }
    } catch (authError) {
      addUploadLog(`❌ Auth test failed: ${authError}`);
    }

    try {
      // Simulate progress
      const progressInterval = setInterval(() => {
        setUploadDebugInfo((prev) => ({
          ...prev,
          uploadProgress: Math.min(prev.uploadProgress + 10, 90),
        }));
      }, 200);

      addUploadLog("📤 Calling attachmentService.uploadFile...");

      // Add detailed request logging
      const startTime = Date.now();
      addUploadLog(`⏰ Upload started at: ${new Date().toISOString()}`);

      const response = await attachmentService.uploadFile(
        uploadDebugInfo.selectedFile,
        userId
      );

      const endTime = Date.now();
      addUploadLog(`⏰ Upload completed in: ${endTime - startTime}ms`);

      clearInterval(progressInterval);

      if (response.code === 200) {
        addUploadLog("✅ Upload successful!");
        addUploadLog(`📊 Response data: ${JSON.stringify(response.data)}`);
        setUploadDebugInfo((prev) => ({
          ...prev,
          uploadStatus: "success",
          uploadProgress: 100,
        }));
      } else {
        addUploadLog(`❌ Upload failed: ${response.msg}`);
        addUploadLog(`📊 Response code: ${response.code}`);
        addUploadLog(`📊 Full response: ${JSON.stringify(response)}`);

        // Special handling for 413 Payload Too Large
        if (response.code === 413) {
          addUploadLog("🚨 FILE TOO LARGE ERROR (413)");
          addUploadLog(
            `📁 File size: ${uploadDebugInfo.selectedFile.size} bytes`
          );
          addUploadLog(
            `📁 File size: ${(
              uploadDebugInfo.selectedFile.size /
              (1024 * 1024)
            ).toFixed(2)} MB`
          );
          addUploadLog("💡 Server limit: 25MB maximum");
          addUploadLog("💡 Try uploading a smaller file");
        } else {
          addUploadLog(`🔍 Non-413 error: ${response.code}`);
          addUploadLog(`🔍 Error message: ${response.msg}`);
        }

        setUploadDebugInfo((prev) => ({
          ...prev,
          uploadStatus: "error",
          lastError: response.msg,
        }));
      }
    } catch (error) {
      addUploadLog(`❌ Upload error: ${error}`);
      addUploadLog(`📊 Error type: ${typeof error}`);
      addUploadLog(
        `📊 Error name: ${error instanceof Error ? error.name : "Unknown"}`
      );
      addUploadLog(
        `📊 Error message: ${
          error instanceof Error ? error.message : String(error)
        }`
      );

      // Check if it's a network error
      if (error instanceof TypeError && error.message.includes("fetch")) {
        addUploadLog("🌐 This appears to be a network/fetch error");
      }

      setUploadDebugInfo((prev) => ({
        ...prev,
        uploadStatus: "error",
        lastError: String(error),
      }));
    }
  };

  const clearUploadLogs = () => {
    setUploadDebugInfo((prev) => ({
      ...prev,
      uploadLogs: [],
      lastError: null,
    }));
    addUploadLog("🧹 Upload logs cleared");
  };

  const testDirectUpload = async () => {
    if (!uploadDebugInfo.selectedFile) {
      addUploadLog("❌ No file selected for direct upload test");
      return;
    }

    const userId = authService.getUserId();
    if (!userId) {
      addUploadLog("❌ No user ID found - user not authenticated");
      return;
    }

    addUploadLog(
      "🔬 Testing direct fetch upload (bypassing attachmentService)..."
    );

    try {
      const authToken = localStorage.getItem("authToken");
      if (!authToken) {
        addUploadLog("❌ No auth token available for direct upload");
        return;
      }

      const formData = new FormData();
      formData.append("file", uploadDebugInfo.selectedFile);

      addUploadLog(
        `📤 Direct upload URL: ${envConfig.apiBaseUrl}/attachments/${userId}`
      );
      addUploadLog(`🔑 Using auth token: ${authToken.substring(0, 20)}...`);

      const response = await fetch(
        `${envConfig.apiBaseUrl}/attachments/${userId}`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${authToken}`,
          },
          body: formData,
        }
      );

      addUploadLog(`📊 Direct upload response status: ${response.status}`);
      addUploadLog(
        `📊 Direct upload response statusText: ${response.statusText}`
      );

      const responseText = await response.text();
      addUploadLog(`📊 Direct upload response body: ${responseText}`);

      if (response.ok) {
        addUploadLog("✅ Direct upload successful!");
      } else {
        addUploadLog(`❌ Direct upload failed with status: ${response.status}`);

        // Special handling for 413 Payload Too Large
        if (response.status === 413) {
          addUploadLog("🚨 DIRECT UPLOAD: FILE TOO LARGE ERROR (413)");
          addUploadLog(
            `📁 File size: ${uploadDebugInfo.selectedFile.size} bytes`
          );
          addUploadLog(
            `📁 File size: ${(
              uploadDebugInfo.selectedFile.size /
              (1024 * 1024)
            ).toFixed(2)} MB`
          );
          addUploadLog("💡 Server limit: 25MB maximum");
          addUploadLog("💡 Try uploading a smaller file");
        }
      }
    } catch (error) {
      addUploadLog(`❌ Direct upload error: ${error}`);
      addUploadLog(`📊 Direct upload error details: ${JSON.stringify(error)}`);
    }
  };

  // Only show on mobile devices
  if (!debugInfo?.isMobile) {
    return null;
  }

  return (
    <Box
      sx={{
        position: "fixed",
        bottom: 16,
        right: 16,
        zIndex: 9999,
        maxWidth: "90vw",
      }}
    >
      <Paper
        elevation={8}
        sx={{
          p: 2,
          backgroundColor: "rgba(0, 0, 0, 0.9)",
          color: "white",
          borderRadius: 2,
        }}
      >
        <Box sx={{ display: "flex", alignItems: "center", mb: 1 }}>
          <BugReport sx={{ mr: 1, color: "orange" }} />
          <Typography variant="h6" sx={{ color: "orange" }}>
            Mobile Debug
          </Typography>
          <Button
            size="small"
            onClick={() => setIsVisible(!isVisible)}
            sx={{ ml: "auto", color: "white" }}
          >
            {isVisible ? "Hide" : "Show"}
          </Button>
        </Box>

        {isVisible && (
          <>
            <Box sx={{ mb: 2 }}>
              <Button
                variant="contained"
                size="small"
                onClick={testApiConnection}
                sx={{ mr: 1, mb: 1 }}
              >
                Test API
              </Button>
              <Button
                variant="outlined"
                size="small"
                onClick={testServerLimits}
                sx={{ mr: 1, mb: 1 }}
              >
                Test Limits
              </Button>
              <Button
                variant="outlined"
                size="small"
                onClick={testRequestSizeAnalysis}
                sx={{ mr: 1, mb: 1 }}
              >
                Analyze Size
              </Button>
              <Button
                variant="outlined"
                size="small"
                onClick={testSmallFiles}
                sx={{ mr: 1, mb: 1 }}
              >
                Test Small Files
              </Button>
              <Button
                variant="outlined"
                size="small"
                onClick={clearStorage}
                sx={{ mr: 1, mb: 1 }}
              >
                Clear Storage
              </Button>
              <Button
                variant="outlined"
                size="small"
                onClick={updateDebugInfo}
                startIcon={<Refresh />}
                sx={{ mb: 1 }}
              >
                Refresh
              </Button>
            </Box>

            {/* Upload Debug Section */}
            <Accordion
              sx={{ backgroundColor: "rgba(255, 255, 255, 0.1)", mb: 1 }}
            >
              <AccordionSummary
                expandIcon={<ExpandMore sx={{ color: "white" }} />}
              >
                <Box sx={{ display: "flex", alignItems: "center" }}>
                  <FileUpload sx={{ mr: 1, color: "orange" }} />
                  <Typography variant="subtitle2">Upload Debug</Typography>
                  {uploadDebugInfo.uploadStatus !== "idle" && (
                    <Chip
                      label={uploadDebugInfo.uploadStatus}
                      size="small"
                      color={
                        uploadDebugInfo.uploadStatus === "success"
                          ? "success"
                          : uploadDebugInfo.uploadStatus === "error"
                          ? "error"
                          : uploadDebugInfo.uploadStatus === "uploading"
                          ? "warning"
                          : "default"
                      }
                      sx={{ ml: 1 }}
                    />
                  )}
                </Box>
              </AccordionSummary>
              <AccordionDetails>
                <Box sx={{ fontSize: "0.75rem" }}>
                  {/* File Selection */}
                  <Box sx={{ mb: 2 }}>
                    <Typography variant="body2" sx={{ mb: 1 }}>
                      <strong>Test File Upload:</strong>
                    </Typography>
                    <input
                      type="file"
                      onChange={handleFileSelect}
                      style={{
                        width: "100%",
                        padding: "4px",
                        marginBottom: "8px",
                        fontSize: "0.75rem",
                      }}
                    />
                    {uploadDebugInfo.selectedFile && (
                      <Typography variant="body2" sx={{ mb: 1 }}>
                        Selected: {uploadDebugInfo.selectedFile.name} (
                        {uploadDebugInfo.selectedFile.size} bytes)
                      </Typography>
                    )}
                    <Box
                      sx={{ display: "flex", gap: 1, mb: 1, flexWrap: "wrap" }}
                    >
                      <Button
                        variant="contained"
                        size="small"
                        onClick={testFileUpload}
                        disabled={
                          !uploadDebugInfo.selectedFile ||
                          uploadDebugInfo.uploadStatus === "uploading"
                        }
                        startIcon={<Upload />}
                        sx={{ fontSize: "0.7rem" }}
                      >
                        Test Upload
                      </Button>
                      <Button
                        variant="outlined"
                        size="small"
                        onClick={testDirectUpload}
                        disabled={!uploadDebugInfo.selectedFile}
                        sx={{ fontSize: "0.7rem" }}
                      >
                        Direct Upload
                      </Button>
                      <Button
                        variant="outlined"
                        size="small"
                        onClick={clearUploadLogs}
                        sx={{ fontSize: "0.7rem" }}
                      >
                        Clear Logs
                      </Button>
                    </Box>
                  </Box>

                  {/* Upload Status */}
                  {uploadDebugInfo.uploadStatus === "uploading" && (
                    <Box sx={{ mb: 2 }}>
                      <Typography variant="body2" sx={{ mb: 1 }}>
                        <strong>Progress:</strong>{" "}
                        {uploadDebugInfo.uploadProgress}%
                      </Typography>
                      <Box
                        sx={{
                          width: "100%",
                          height: 4,
                          backgroundColor: "rgba(255,255,255,0.3)",
                          borderRadius: 2,
                          overflow: "hidden",
                        }}
                      >
                        <Box
                          sx={{
                            width: `${uploadDebugInfo.uploadProgress}%`,
                            height: "100%",
                            backgroundColor: "orange",
                            transition: "width 0.3s ease",
                          }}
                        />
                      </Box>
                    </Box>
                  )}

                  {/* Error Display */}
                  {uploadDebugInfo.lastError && (
                    <Alert severity="error" sx={{ mb: 2, fontSize: "0.7rem" }}>
                      <strong>Last Error:</strong> {uploadDebugInfo.lastError}
                    </Alert>
                  )}

                  {/* Upload Logs */}
                  <Box sx={{ mb: 1 }}>
                    <Typography variant="body2" sx={{ mb: 1 }}>
                      <strong>Upload Logs:</strong>
                    </Typography>
                    <Box
                      sx={{
                        backgroundColor: "rgba(0,0,0,0.3)",
                        padding: 1,
                        borderRadius: 1,
                        maxHeight: 150,
                        overflow: "auto",
                        fontFamily: "monospace",
                        fontSize: "0.65rem",
                      }}
                    >
                      {uploadDebugInfo.uploadLogs.length === 0 ? (
                        <Typography variant="body2" color="text.secondary">
                          No logs yet. Select a file and test upload.
                        </Typography>
                      ) : (
                        uploadDebugInfo.uploadLogs.map((log, index) => (
                          <Typography
                            key={index}
                            variant="body2"
                            sx={{ mb: 0.5 }}
                          >
                            {log}
                          </Typography>
                        ))
                      )}
                    </Box>
                  </Box>
                </Box>
              </AccordionDetails>
            </Accordion>

            <Accordion sx={{ backgroundColor: "rgba(255, 255, 255, 0.1)" }}>
              <AccordionSummary
                expandIcon={<ExpandMore sx={{ color: "white" }} />}
              >
                <Typography variant="subtitle2">Debug Info</Typography>
              </AccordionSummary>
              <AccordionDetails>
                <Box sx={{ fontSize: "0.75rem", fontFamily: "monospace" }}>
                  <Typography variant="body2" sx={{ mb: 1 }}>
                    <strong>API Base URL:</strong> {debugInfo?.apiBaseUrl}
                  </Typography>
                  <Typography variant="body2" sx={{ mb: 1 }}>
                    <strong>Current URL:</strong> {window.location.href}
                  </Typography>
                  <Typography variant="body2" sx={{ mb: 1 }}>
                    <strong>User Agent:</strong> {debugInfo?.userAgent}
                  </Typography>
                  <Typography variant="body2" sx={{ mb: 1 }}>
                    <strong>Network:</strong>{" "}
                    <Chip
                      label={debugInfo?.networkStatus}
                      size="small"
                      color={
                        debugInfo?.networkStatus === "Online"
                          ? "success"
                          : "error"
                      }
                    />
                  </Typography>
                  <Typography variant="body2" sx={{ mb: 1 }}>
                    <strong>File API Support:</strong>{" "}
                    <Chip
                      label={
                        typeof File !== "undefined"
                          ? "Supported"
                          : "Not Supported"
                      }
                      size="small"
                      color={typeof File !== "undefined" ? "success" : "error"}
                    />
                  </Typography>
                  <Typography variant="body2" sx={{ mb: 1 }}>
                    <strong>FormData Support:</strong>{" "}
                    <Chip
                      label={
                        typeof FormData !== "undefined"
                          ? "Supported"
                          : "Not Supported"
                      }
                      size="small"
                      color={
                        typeof FormData !== "undefined" ? "success" : "error"
                      }
                    />
                  </Typography>
                  <Typography variant="body2" sx={{ mb: 1 }}>
                    <strong>Storage:</strong>
                  </Typography>
                  <Box sx={{ ml: 1 }}>
                    {Object.entries(debugInfo?.localStorage || {}).map(
                      ([key, value]) => (
                        <Typography key={key} variant="body2">
                          {key}: <Chip label={String(value)} size="small" />
                        </Typography>
                      )
                    )}
                  </Box>
                  <Typography variant="body2" sx={{ mt: 1 }}>
                    <strong>Time:</strong> {debugInfo?.timestamp}
                  </Typography>
                </Box>
              </AccordionDetails>
            </Accordion>

            <Alert severity="info" sx={{ mt: 1, fontSize: "0.75rem" }}>
              Check browser console for detailed logs
            </Alert>
          </>
        )}
      </Paper>
    </Box>
  );
};

export default MobileDebugPanel;

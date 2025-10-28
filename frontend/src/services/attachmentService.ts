import { attachmentApi } from "./generatedApi";

export interface ApiResponse<T = any> {
  code: number;
  msg: string;
  data?: T;
}

class AttachmentService {
  /**
   * Upload file without linking to task
   */
  async uploadFile(file: File, userId: string): Promise<ApiResponse<any>> {
    // Enhanced mobile debugging
    const isMobile =
      /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
        navigator.userAgent
      );

    if (isMobile) {
      console.log("📱 AttachmentService Debug - uploadFile:", {
        fileName: file.name,
        fileSize: file.size,
        fileType: file.type,
        userId: userId,
        userAgent: navigator.userAgent,
        timestamp: new Date().toISOString(),
        apiBaseUrl: window.location.origin,
      });
    }

    try {
      if (isMobile) {
        console.log(
          "📱 AttachmentService Debug - Calling attachmentApi.upload..."
        );
        console.log("📱 AttachmentService Debug - Request details:", {
          url: `${window.location.origin}/api/attachments/${userId}`,
          method: "POST",
          contentType: "multipart/form-data",
          fileSize: file.size,
          fileName: file.name,
          fileType: file.type,
          userId: userId,
        });
      }

      const response = await attachmentApi.upload(userId, file);

      if (isMobile) {
        console.log(
          "📱 AttachmentService Debug - Upload API response:",
          response
        );
      }

      return {
        code: 200,
        msg: "File uploaded successfully",
        data: response.data,
      };
    } catch (error: any) {
      if (isMobile) {
        console.error("📱 AttachmentService Debug - Upload error:", error);
        console.error("📱 AttachmentService Debug - Error details:", {
          name: error.name,
          message: error.message,
          status: error.response?.status,
          statusText: error.response?.statusText,
          data: error.response?.data,
          config: {
            url: error.config?.url,
            method: error.config?.method,
            headers: error.config?.headers,
          },
        });
      }
      console.error("Upload file error:", error);

      // Enhanced error message handling
      let errorMessage = "Failed to upload file.";
      let errorCode = error.response?.status || 500;

      if (error.response?.data) {
        if (typeof error.response.data === "string") {
          errorMessage = error.response.data;
        } else if (error.response.data.msg) {
          errorMessage = error.response.data.msg;
        } else if (error.response.data.message) {
          errorMessage = error.response.data.message;
        }
      }

      // Special handling for 413 errors
      if (errorCode === 413) {
        errorMessage = "File too large. Maximum allowed size is 25MB.";
      }

      return {
        code: errorCode,
        msg: errorMessage,
      };
    }
  }

  /**
   * Upload file and attach to task
   */
  async uploadFileForTask(
    taskId: string,
    file: File,
    userId: string
  ): Promise<ApiResponse<any>> {
    try {
      const response = await attachmentApi.uploadForTask(taskId, userId, file);
      return {
        code: 200,
        msg: "File uploaded and attached successfully",
        data: response.data,
      };
    } catch (error: any) {
      console.error("Upload file for task error:", error);

      return {
        code: error.response?.status || 500,
        msg: error.response?.data?.msg || "Failed to upload file for task.",
      };
    }
  }

  /**
   * Get attachments for a task
   */
  async getTaskAttachments(
    taskId: string,
    userId: string
  ): Promise<ApiResponse<any>> {
    try {
      const response = await attachmentApi.listForTask(taskId, userId);
      return {
        code: 200,
        msg: "Success",
        data: response.data,
      };
    } catch (error: any) {
      console.error("Get task attachments error:", error);

      return {
        code: error.response?.status || 500,
        msg: error.response?.data?.msg || "Failed to get task attachments.",
      };
    }
  }

  async getUserAttachments(userId: string): Promise<ApiResponse<any>> {
    try {
      const response = await attachmentApi.listForUser(userId);
      return {
        code: 200,
        msg: "Success",
        data: response.data,
      };
    } catch (error: any) {
      console.error("Get user attachments error:", error);

      return {
        code: error.response?.status || 500,
        msg: error.response?.data?.msg || "Failed to get user attachments.",
      };
    }
  }

  /**
   * Attach existing file to task
   */
  async attachFileToTask(
    attachmentId: string,
    taskId: string,
    userId: string
  ): Promise<ApiResponse<any>> {
    try {
      const response = await attachmentApi.attach(attachmentId, taskId, userId);
      return {
        code: 200,
        msg: "File attached successfully",
        data: response.data,
      };
    } catch (error: any) {
      console.error("Attach file to task error:", error);

      return {
        code: error.response?.status || 500,
        msg: error.response?.data?.msg || "Failed to attach file to task.",
      };
    }
  }

  /**
   * Detach file from task
   */
  async detachFileFromTask(
    attachmentId: string,
    userId: string
  ): Promise<ApiResponse<any>> {
    try {
      const response = await attachmentApi.detach(attachmentId, userId);
      return {
        code: 200,
        msg: "File detached successfully",
        data: response.data,
      };
    } catch (error: any) {
      console.error("Detach file from task error:", error);

      return {
        code: error.response?.status || 500,
        msg: error.response?.data?.msg || "Failed to detach file from task.",
      };
    }
  }

  /**
   * Download file
   */
  async downloadFile(
    attachmentId: string,
    userId: string
  ): Promise<ApiResponse<Blob>> {
    try {
      const response = await attachmentApi.download(attachmentId, userId, {
        responseType: "blob",
      });
      return {
        code: 200,
        msg: "File downloaded successfully",
        data: response.data as unknown as Blob,
      };
    } catch (error: any) {
      console.error("Download file error:", error);

      return {
        code: error.response?.status || 500,
        msg: error.response?.data?.msg || "Failed to download file.",
      };
    }
  }

  /**
   * Delete attachment
   */
  async deleteAttachment(
    attachmentId: string,
    userId: string
  ): Promise<ApiResponse> {
    // Enhanced mobile debugging
    const isMobile =
      /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
        navigator.userAgent
      );

    if (isMobile) {
      console.log("📱 AttachmentService Debug - deleteAttachment:", {
        attachmentId: attachmentId,
        userId: userId,
        userAgent: navigator.userAgent,
        timestamp: new Date().toISOString(),
        apiBaseUrl: window.location.origin,
      });
    }

    try {
      if (isMobile) {
        console.log(
          "📱 AttachmentService Debug - Calling attachmentApi._delete..."
        );
      }

      await attachmentApi._delete(attachmentId, userId);

      if (isMobile) {
        console.log("📱 AttachmentService Debug - Delete API call successful");
      }

      return {
        code: 200,
        msg: "Attachment deleted successfully",
      };
    } catch (error: any) {
      if (isMobile) {
        console.error("📱 AttachmentService Debug - Delete error:", error);
        console.error("📱 AttachmentService Debug - Error details:", {
          name: error.name,
          message: error.message,
          status: error.response?.status,
          statusText: error.response?.statusText,
          data: error.response?.data,
          config: {
            url: error.config?.url,
            method: error.config?.method,
            headers: error.config?.headers,
          },
        });
      }
      console.error("Delete attachment error:", error);

      return {
        code: error.response?.status || 500,
        msg: error.response?.data?.msg || "Failed to delete attachment.",
      };
    }
  }

  /**
   * Helper method to trigger file download
   */
  async downloadAndSaveFile(
    attachmentId: string,
    fileName: string,
    userId: string
  ): Promise<boolean> {
    try {
      const response = await this.downloadFile(attachmentId, userId);

      if (response.code === 200 && response.data) {
        // Create download link
        const url = window.URL.createObjectURL(response.data);
        const link = document.createElement("a");
        link.href = url;
        link.download = fileName;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        window.URL.revokeObjectURL(url);
        return true;
      }
      return false;
    } catch (error) {
      console.error("Download and save file error:", error);
      return false;
    }
  }

  /**
   * Get file content as text for text files
   */
  async getFileAsText(
    attachmentId: string,
    userId: string
  ): Promise<ApiResponse<string>> {
    try {
      const response = await attachmentApi.download(attachmentId, userId, {
        responseType: "text",
      });
      return {
        code: 200,
        msg: "File content retrieved successfully",
        data: response.data as unknown as string,
      };
    } catch (error: any) {
      console.error("Get file as text error:", error);

      return {
        code: error.response?.status || 500,
        msg: error.response?.data?.msg || "Failed to get file content.",
      };
    }
  }
}

export const attachmentService = new AttachmentService();
export default attachmentService;

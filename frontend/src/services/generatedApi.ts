import {
  Configuration,
  AuthenticationApi,
  TaskManagementApi,
  UserManagementApi,
  FileAttachmentsApi,
  type AuthResponse,
  type LoginRequest,
} from "../generated/api";
import { envConfig } from "../config/env";

// Create configuration with authentication
const configuration = new Configuration({
  basePath: envConfig.apiBaseUrl,
  accessToken: () => {
    // Get JWT token from localStorage
    return localStorage.getItem("authToken") || "";
  },
  // Add custom headers for X-User-Id
  baseOptions: {
    headers: {
      get "X-User-Id"() {
        return localStorage.getItem("userId") || "";
      },
    },
  },
});

// Create API instances
export const authApi = new AuthenticationApi(configuration);
export const taskApi = new TaskManagementApi(configuration);
export const userApi = new UserManagementApi(configuration);
export const attachmentApi = new FileAttachmentsApi(configuration);

// Export the API instances and types
export { type AuthResponse, type LoginRequest };

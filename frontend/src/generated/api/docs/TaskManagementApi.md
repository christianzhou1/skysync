# TaskManagementApi

All URIs are relative to *http://localhost:8080/api*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**createTask**](#createtask) | **POST** /tasks | Create new task|
|[**deleteTask**](#deletetask) | **DELETE** /tasks/id/{id} | Delete task|
|[**getRootTasks**](#getroottasks) | **GET** /tasks/root | Get root tasks|
|[**getSubtasks**](#getsubtasks) | **GET** /tasks/id/{id}/subtasks | Get direct subtasks of a task|
|[**getSubtasksRecursively**](#getsubtasksrecursively) | **GET** /tasks/id/{id}/subtasks/recursive | Get all subtasks recursively|
|[**getTaskById**](#gettaskbyid) | **GET** /tasks/id/{id} | Get task by ID|
|[**getTaskDetail**](#gettaskdetail) | **GET** /tasks/id/{id}/detail | Get task detail by ID|
|[**getTaskWithSubtasks**](#gettaskwithsubtasks) | **GET** /tasks/id/{id}/with-subtasks | Get task with subtasks|
|[**insertMock**](#insertmock) | **POST** /tasks/mock | Create mock task|
|[**insertMock1**](#insertmock1) | **POST** /tasks/mock/ | Create mock task|
|[**listAllTaskDetails**](#listalltaskdetails) | **GET** /tasks/details | Get all task details|
|[**listAllTasks**](#listalltasks) | **GET** /tasks/listalltasks | Get all tasks|
|[**listTasks**](#listtasks) | **GET** /tasks | Get list of tasks|
|[**reorderTask**](#reordertask) | **PATCH** /tasks/{id}/reorder | Reorder task|
|[**setCompleted**](#setcompleted) | **PATCH** /tasks/id/{id}/complete | Set task completion status|
|[**updateTask**](#updatetask) | **PUT** /tasks/id/{id} | Update task|

# **createTask**
> TaskSummary createTask(createTaskRequest)

Create a new todo task or subtask

### Example

```typescript
import {
    TaskManagementApi,
    Configuration,
    CreateTaskRequest
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let xUserId: string; // (default to undefined)
let createTaskRequest: CreateTaskRequest; //

const { status, data } = await apiInstance.createTask(
    xUserId,
    createTaskRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **createTaskRequest** | **CreateTaskRequest**|  | |
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**TaskSummary**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**201** | Task created successfully |  -  |
|**400** | Invalid task data |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteTask**
> deleteTask()

Soft delete a task (marks as deleted but preserves data)

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let id: string; //Task ID (default to undefined)
let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.deleteTask(
    id,
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | Task ID | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

void (empty response body)

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**204** | Task deleted successfully |  -  |
|**404** | Task not found |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRootTasks**
> Array<TaskSummary> getRootTasks()

Retrieve all root tasks (tasks without parent tasks)

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.getRootTasks(
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**Array<TaskSummary>**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Root tasks retrieved successfully |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSubtasks**
> Array<TaskSummary> getSubtasks()

Retrieve all direct subtasks of a specific task

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let id: string; //Parent task ID (default to undefined)
let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.getSubtasks(
    id,
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | Parent task ID | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**Array<TaskSummary>**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Subtasks retrieved successfully |  -  |
|**404** | Parent task not found |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSubtasksRecursively**
> Array<TaskSummary> getSubtasksRecursively()

Retrieve all subtasks of a task up to a specified depth

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let id: string; //Parent task ID (default to undefined)
let xUserId: string; // (default to undefined)
let maxDepth: number; //Maximum depth to traverse (optional) (default to 3)

const { status, data } = await apiInstance.getSubtasksRecursively(
    id,
    xUserId,
    maxDepth
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | Parent task ID | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|
| **maxDepth** | [**number**] | Maximum depth to traverse | (optional) defaults to 3|


### Return type

**Array<TaskSummary>**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Subtasks retrieved successfully |  -  |
|**404** | Parent task not found |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTaskById**
> TaskSummary getTaskById()

Retrieve basic task information by ID

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let id: string; //Task ID (default to undefined)
let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.getTaskById(
    id,
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | Task ID | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**TaskSummary**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**404** | Task not found |  -  |
|**200** | Task retrieved successfully |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTaskDetail**
> TaskDetailInfo getTaskDetail()

Retrieve detailed information about a specific task including attachments

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let id: string; //Task ID (default to undefined)
let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.getTaskDetail(
    id,
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | Task ID | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**TaskDetailInfo**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**404** | Task not found |  -  |
|**200** | Task detail retrieved successfully |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTaskWithSubtasks**
> TaskSummary getTaskWithSubtasks()

Retrieve a task with its subtasks organized in a hierarchical structure

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let id: string; //Task ID (default to undefined)
let xUserId: string; // (default to undefined)
let maxDepth: number; //Maximum depth to traverse (optional) (default to 3)

const { status, data } = await apiInstance.getTaskWithSubtasks(
    id,
    xUserId,
    maxDepth
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | Task ID | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|
| **maxDepth** | [**number**] | Maximum depth to traverse | (optional) defaults to 3|


### Return type

**TaskSummary**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Task with subtasks retrieved successfully |  -  |
|**404** | Task not found |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **insertMock**
> TaskSummary insertMock()

Create a sample task for testing purposes

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.insertMock(
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**TaskSummary**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Mock task created successfully |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **insertMock1**
> TaskSummary insertMock1()

Create a sample task for testing purposes

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.insertMock1(
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**TaskSummary**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Mock task created successfully |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAllTaskDetails**
> Array<TaskDetailInfo> listAllTaskDetails()

Retrieve detailed information for all tasks including attachments

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.listAllTaskDetails(
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**Array<TaskDetailInfo>**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Task details retrieved successfully |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAllTasks**
> Array<TaskSummary> listAllTasks()

Retrieve all tasks including deleted ones

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.listAllTasks(
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**Array<TaskSummary>**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | All tasks retrieved successfully |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTasks**
> Array<TaskSummary> listTasks()

Retrieve a list of tasks with sorting options

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let xUserId: string; // (default to undefined)
let page: number; //Page number (0-based) (optional) (default to 0)
let size: number; //Page size (optional) (default to 10)
let sort: string; //Sort criteria (e.g., \'createdAt,desc\') (optional) (default to 'createdAt,desc')

const { status, data } = await apiInstance.listTasks(
    xUserId,
    page,
    size,
    sort
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **xUserId** | [**string**] |  | defaults to undefined|
| **page** | [**number**] | Page number (0-based) | (optional) defaults to 0|
| **size** | [**number**] | Page size | (optional) defaults to 10|
| **sort** | [**string**] | Sort criteria (e.g., \&#39;createdAt,desc\&#39;) | (optional) defaults to 'createdAt,desc'|


### Return type

**Array<TaskSummary>**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Tasks retrieved successfully |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reorderTask**
> Task reorderTask()

Change the display order of a task within its hierarchy level

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let id: string; // (default to undefined)
let newDisplayOrder: number; // (default to undefined)
let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.reorderTask(
    id,
    newDisplayOrder,
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] |  | defaults to undefined|
| **newDisplayOrder** | [**number**] |  | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**Task**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**404** | Task not found |  -  |
|**200** | Task reordered successfully |  -  |
|**400** | Invalid display order |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setCompleted**
> TaskSummary setCompleted()

Mark a task as completed or incomplete

### Example

```typescript
import {
    TaskManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let id: string; //Task ID (default to undefined)
let value: boolean; //Completion status (default to undefined)
let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.setCompleted(
    id,
    value,
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | Task ID | defaults to undefined|
| **value** | [**boolean**] | Completion status | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**TaskSummary**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**404** | Task not found |  -  |
|**200** | Task completion status updated |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateTask**
> TaskSummary updateTask(updateTaskRequest)

Update an existing task (only non-null fields will be updated)

### Example

```typescript
import {
    TaskManagementApi,
    Configuration,
    UpdateTaskRequest
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new TaskManagementApi(configuration);

let id: string; //Task ID (default to undefined)
let xUserId: string; // (default to undefined)
let updateTaskRequest: UpdateTaskRequest; //

const { status, data } = await apiInstance.updateTask(
    id,
    xUserId,
    updateTaskRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **updateTaskRequest** | **UpdateTaskRequest**|  | |
| **id** | [**string**] | Task ID | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**TaskSummary**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**404** | Task not found |  -  |
|**400** | Invalid task data |  -  |
|**200** | Task updated successfully |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


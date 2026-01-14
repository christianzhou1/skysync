## @skysync/api-client@1.0.0

This generator creates TypeScript/JavaScript client that utilizes [axios](https://github.com/axios/axios). The generated Node module can be used in the following environments:

Environment
* Node.js
* Webpack
* Browserify

Language level
* ES5 - you must have a Promises/A+ library installed
* ES6

Module system
* CommonJS
* ES6 module system

It can be used in both TypeScript and JavaScript. In TypeScript, the definition will be automatically resolved via `package.json`. ([Reference](https://www.typescriptlang.org/docs/handbook/declaration-files/consumption.html))

### Building

To build and compile the typescript sources to javascript use:
```
npm install
npm run build
```

### Publishing

First build the package then run `npm publish`

### Consuming

navigate to the folder of your consuming project and run one of the following commands.

_published:_

```
npm install @skysync/api-client@1.0.0 --save
```

_unPublished (not recommended):_

```
npm install PATH_TO_GENERATED_PACKAGE --save
```

### Documentation for API Endpoints

All URIs are relative to *http://localhost:8080/api*

Class | Method | HTTP request | Description
------------ | ------------- | ------------- | -------------
*ActuatorApi* | [**health**](docs/ActuatorApi.md#health) | **GET** /actuator/health | Actuator web endpoint \&#39;health\&#39;
*ActuatorApi* | [**info**](docs/ActuatorApi.md#info) | **GET** /actuator/info | Actuator web endpoint \&#39;info\&#39;
*ActuatorApi* | [**links**](docs/ActuatorApi.md#links) | **GET** /actuator | Actuator root web endpoint
*AuthenticationApi* | [**getCurrentUser**](docs/AuthenticationApi.md#getcurrentuser) | **GET** /auth/me | Get current user
*AuthenticationApi* | [**login**](docs/AuthenticationApi.md#login) | **POST** /auth/login | User login
*AuthenticationApi* | [**logout**](docs/AuthenticationApi.md#logout) | **POST** /auth/logout | User logout
*DebugControllerApi* | [**debugAuth**](docs/DebugControllerApi.md#debugauth) | **GET** /debug/auth | 
*DebugControllerApi* | [**debugPublic**](docs/DebugControllerApi.md#debugpublic) | **GET** /debug/public | 
*EnvironmentControllerApi* | [**getEnvironmentInfo**](docs/EnvironmentControllerApi.md#getenvironmentinfo) | **GET** /environment/info | 
*FileAttachmentsApi* | [**_delete**](docs/FileAttachmentsApi.md#_delete) | **DELETE** /attachments/{id} | Delete attachment
*FileAttachmentsApi* | [**attach**](docs/FileAttachmentsApi.md#attach) | **POST** /attachments/{id}/attach/{taskId} | Attach file to task
*FileAttachmentsApi* | [**detach**](docs/FileAttachmentsApi.md#detach) | **POST** /attachments/{id}/detach | Detach file from task
*FileAttachmentsApi* | [**download**](docs/FileAttachmentsApi.md#download) | **GET** /attachments/{id}/download | Download file
*FileAttachmentsApi* | [**listForTask**](docs/FileAttachmentsApi.md#listfortask) | **GET** /attachments/task/{taskId} | List task attachments
*FileAttachmentsApi* | [**listForUser**](docs/FileAttachmentsApi.md#listforuser) | **GET** /attachments/ | List user attachments
*FileAttachmentsApi* | [**upload**](docs/FileAttachmentsApi.md#upload) | **POST** /attachments | Upload file
*FileAttachmentsApi* | [**uploadForTask**](docs/FileAttachmentsApi.md#uploadfortask) | **POST** /attachments/task/{taskId} | Upload file for task
*HelloControllerApi* | [**hello**](docs/HelloControllerApi.md#hello) | **GET** /hello | 
*TaskManagementApi* | [**createTask**](docs/TaskManagementApi.md#createtask) | **POST** /tasks | Create new task
*TaskManagementApi* | [**deleteTask**](docs/TaskManagementApi.md#deletetask) | **DELETE** /tasks/id/{id} | Delete task
*TaskManagementApi* | [**getRootTasks**](docs/TaskManagementApi.md#getroottasks) | **GET** /tasks/root | Get root tasks
*TaskManagementApi* | [**getSubtasks**](docs/TaskManagementApi.md#getsubtasks) | **GET** /tasks/id/{id}/subtasks | Get direct subtasks of a task
*TaskManagementApi* | [**getSubtasksRecursively**](docs/TaskManagementApi.md#getsubtasksrecursively) | **GET** /tasks/id/{id}/subtasks/recursive | Get all subtasks recursively
*TaskManagementApi* | [**getTaskById**](docs/TaskManagementApi.md#gettaskbyid) | **GET** /tasks/id/{id} | Get task by ID
*TaskManagementApi* | [**getTaskDetail**](docs/TaskManagementApi.md#gettaskdetail) | **GET** /tasks/id/{id}/detail | Get task detail by ID
*TaskManagementApi* | [**getTaskWithSubtasks**](docs/TaskManagementApi.md#gettaskwithsubtasks) | **GET** /tasks/id/{id}/with-subtasks | Get task with subtasks
*TaskManagementApi* | [**insertMock**](docs/TaskManagementApi.md#insertmock) | **POST** /tasks/mock | Create mock task
*TaskManagementApi* | [**insertMock1**](docs/TaskManagementApi.md#insertmock1) | **POST** /tasks/mock/ | Create mock task
*TaskManagementApi* | [**listAllTaskDetails**](docs/TaskManagementApi.md#listalltaskdetails) | **GET** /tasks/details | Get all task details
*TaskManagementApi* | [**listAllTasks**](docs/TaskManagementApi.md#listalltasks) | **GET** /tasks/listalltasks | Get all tasks
*TaskManagementApi* | [**listTasks**](docs/TaskManagementApi.md#listtasks) | **GET** /tasks | Get list of tasks
*TaskManagementApi* | [**reorderTask**](docs/TaskManagementApi.md#reordertask) | **PATCH** /tasks/{id}/reorder | Reorder task
*TaskManagementApi* | [**setCompleted**](docs/TaskManagementApi.md#setcompleted) | **PATCH** /tasks/id/{id}/complete | Set task completion status
*TaskManagementApi* | [**updateTask**](docs/TaskManagementApi.md#updatetask) | **PUT** /tasks/id/{id} | Update task
*UserManagementApi* | [**activateUser**](docs/UserManagementApi.md#activateuser) | **PATCH** /users/id/{id}/activate | Activate user
*UserManagementApi* | [**createUser**](docs/UserManagementApi.md#createuser) | **POST** /users | Create new user
*UserManagementApi* | [**deactivateUser**](docs/UserManagementApi.md#deactivateuser) | **PATCH** /users/id/{id}/deactivate | Deactivate user
*UserManagementApi* | [**getAllUsers**](docs/UserManagementApi.md#getallusers) | **GET** /users/get-all-users | Get all users
*UserManagementApi* | [**getUserById**](docs/UserManagementApi.md#getuserbyid) | **GET** /users/id/{id} | Get user by ID
*UserManagementApi* | [**getUserByUsername**](docs/UserManagementApi.md#getuserbyusername) | **GET** /users/username/{username} | Get user by username
*UserManagementApi* | [**getUserTasks**](docs/UserManagementApi.md#getusertasks) | **GET** /users/id/{id}/tasks | Get user tasks
*UserManagementApi* | [**updateUser**](docs/UserManagementApi.md#updateuser) | **PUT** /users/id/{id} | Update user


### Documentation For Models

 - [Attachment](docs/Attachment.md)
 - [AttachmentInfo](docs/AttachmentInfo.md)
 - [AuthResponse](docs/AuthResponse.md)
 - [CommentInfo](docs/CommentInfo.md)
 - [CreateTaskRequest](docs/CreateTaskRequest.md)
 - [CreateUserRequest](docs/CreateUserRequest.md)
 - [Link](docs/Link.md)
 - [LoginRequest](docs/LoginRequest.md)
 - [Task](docs/Task.md)
 - [TaskAttachment](docs/TaskAttachment.md)
 - [TaskDetailInfo](docs/TaskDetailInfo.md)
 - [TaskSummary](docs/TaskSummary.md)
 - [UpdateTaskRequest](docs/UpdateTaskRequest.md)
 - [UpdateUserRequest](docs/UpdateUserRequest.md)
 - [User](docs/User.md)
 - [UserInfo](docs/UserInfo.md)
 - [UserSummary](docs/UserSummary.md)


<a id="documentation-for-authorization"></a>
## Documentation For Authorization


Authentication schemes defined for the API:
<a id="BearerAuth"></a>
### BearerAuth

- **Type**: Bearer authentication (JWT)

<a id="XUserIdHeader"></a>
### XUserIdHeader

- **Type**: API key
- **API key parameter name**: X-User-Id
- **Location**: HTTP header


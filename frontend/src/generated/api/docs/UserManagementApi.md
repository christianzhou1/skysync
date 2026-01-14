# UserManagementApi

All URIs are relative to *http://localhost:8080/api*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**activateUser**](#activateuser) | **PATCH** /users/id/{id}/activate | Activate user|
|[**createUser**](#createuser) | **POST** /users | Create new user|
|[**deactivateUser**](#deactivateuser) | **PATCH** /users/id/{id}/deactivate | Deactivate user|
|[**getAllUsers**](#getallusers) | **GET** /users/get-all-users | Get all users|
|[**getUserById**](#getuserbyid) | **GET** /users/id/{id} | Get user by ID|
|[**getUserByUsername**](#getuserbyusername) | **GET** /users/username/{username} | Get user by username|
|[**getUserTasks**](#getusertasks) | **GET** /users/id/{id}/tasks | Get user tasks|
|[**updateUser**](#updateuser) | **PUT** /users/id/{id} | Update user|

# **activateUser**
> activateUser()

Activate a user account

### Example

```typescript
import {
    UserManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new UserManagementApi(configuration);

let id: string; //User ID (default to undefined)

const { status, data } = await apiInstance.activateUser(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | User ID | defaults to undefined|


### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**204** | User activated successfully |  -  |
|**404** | User not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createUser**
> UserInfo createUser(createUserRequest)

Create a new user account

### Example

```typescript
import {
    UserManagementApi,
    Configuration,
    CreateUserRequest
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new UserManagementApi(configuration);

let createUserRequest: CreateUserRequest; //

const { status, data } = await apiInstance.createUser(
    createUserRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **createUserRequest** | **CreateUserRequest**|  | |


### Return type

**UserInfo**

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**409** | Username or email already exists |  -  |
|**201** | User created successfully |  -  |
|**400** | Invalid user data |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deactivateUser**
> deactivateUser()

Deactivate a user account

### Example

```typescript
import {
    UserManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new UserManagementApi(configuration);

let id: string; //User ID (default to undefined)

const { status, data } = await apiInstance.deactivateUser(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | User ID | defaults to undefined|


### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**204** | User deactivated successfully |  -  |
|**404** | User not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAllUsers**
> Array<UserSummary> getAllUsers()

Retrieve a list of all users in the system

### Example

```typescript
import {
    UserManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new UserManagementApi(configuration);

const { status, data } = await apiInstance.getAllUsers();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**Array<UserSummary>**

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Users retrieved successfully |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserById**
> UserInfo getUserById()

Retrieve user information by user ID

### Example

```typescript
import {
    UserManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new UserManagementApi(configuration);

let id: string; //User ID (default to undefined)

const { status, data } = await apiInstance.getUserById(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | User ID | defaults to undefined|


### Return type

**UserInfo**

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | User found |  -  |
|**404** | User not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserByUsername**
> UserInfo getUserByUsername()

Retrieve user information by username

### Example

```typescript
import {
    UserManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new UserManagementApi(configuration);

let username: string; //Username (default to undefined)

const { status, data } = await apiInstance.getUserByUsername(
    username
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **username** | [**string**] | Username | defaults to undefined|


### Return type

**UserInfo**

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | User found |  -  |
|**404** | User not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserTasks**
> Array<TaskSummary> getUserTasks()

Retrieve all tasks for a specific user

### Example

```typescript
import {
    UserManagementApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new UserManagementApi(configuration);

let id: string; //User ID (default to undefined)

const { status, data } = await apiInstance.getUserTasks(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | User ID | defaults to undefined|


### Return type

**Array<TaskSummary>**

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | User tasks retrieved successfully |  -  |
|**404** | User not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateUser**
> UserInfo updateUser(updateUserRequest)

Update user information

### Example

```typescript
import {
    UserManagementApi,
    Configuration,
    UpdateUserRequest
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new UserManagementApi(configuration);

let id: string; //User ID (default to undefined)
let updateUserRequest: UpdateUserRequest; //

const { status, data } = await apiInstance.updateUser(
    id,
    updateUserRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **updateUserRequest** | **UpdateUserRequest**|  | |
| **id** | [**string**] | User ID | defaults to undefined|


### Return type

**UserInfo**

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | User updated successfully |  -  |
|**400** | Invalid user data |  -  |
|**404** | User not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


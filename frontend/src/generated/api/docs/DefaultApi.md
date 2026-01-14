# DefaultApi

All URIs are relative to *http://localhost:8080/api*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**attachmentsGet**](#attachmentsget) | **GET** /attachments/ | Get user attachments|
|[**authLoginPost**](#authloginpost) | **POST** /auth/login | User login|
|[**tasksGet**](#tasksget) | **GET** /tasks | Get list of tasks|

# **attachmentsGet**
> attachmentsGet()

Retrieve all attachments for the current user

### Example

```typescript
import {
    DefaultApi,
    Configuration
} from '@todo/api-client';

const configuration = new Configuration();
const apiInstance = new DefaultApi(configuration);

let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.attachmentsGet(
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **xUserId** | [**string**] |  | defaults to undefined|


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
|**200** | Attachments retrieved successfully |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authLoginPost**
> AuthResponse authLoginPost(authLoginPostRequest)

Authenticate user and return JWT token

### Example

```typescript
import {
    DefaultApi,
    Configuration,
    AuthLoginPostRequest
} from '@todo/api-client';

const configuration = new Configuration();
const apiInstance = new DefaultApi(configuration);

let authLoginPostRequest: AuthLoginPostRequest; //

const { status, data } = await apiInstance.authLoginPost(
    authLoginPostRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **authLoginPostRequest** | **AuthLoginPostRequest**|  | |


### Return type

**AuthResponse**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Login successful |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tasksGet**
> tasksGet()

Retrieve a list of tasks with sorting options

### Example

```typescript
import {
    DefaultApi,
    Configuration
} from '@todo/api-client';

const configuration = new Configuration();
const apiInstance = new DefaultApi(configuration);

let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.tasksGet(
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **xUserId** | [**string**] |  | defaults to undefined|


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
|**200** | Tasks retrieved successfully |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


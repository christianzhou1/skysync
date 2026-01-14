# FileAttachmentsApi

All URIs are relative to *http://localhost:8080/api*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**_delete**](#_delete) | **DELETE** /attachments/{id} | Delete attachment|
|[**attach**](#attach) | **POST** /attachments/{id}/attach/{taskId} | Attach file to task|
|[**detach**](#detach) | **POST** /attachments/{id}/detach | Detach file from task|
|[**download**](#download) | **GET** /attachments/{id}/download | Download file|
|[**listForTask**](#listfortask) | **GET** /attachments/task/{taskId} | List task attachments|
|[**listForUser**](#listforuser) | **GET** /attachments/ | List user attachments|
|[**upload**](#upload) | **POST** /attachments | Upload file|
|[**uploadForTask**](#uploadfortask) | **POST** /attachments/task/{taskId} | Upload file for task|

# **_delete**
> _delete()

Delete attachment metadata and underlying file

### Example

```typescript
import {
    FileAttachmentsApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new FileAttachmentsApi(configuration);

let id: string; //Attachment ID (default to undefined)
let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance._delete(
    id,
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | Attachment ID | defaults to undefined|
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
|**204** | Attachment deleted successfully |  -  |
|**404** | Attachment not found |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **attach**
> AttachmentInfo attach()

Attach an existing unlinked file to a task

### Example

```typescript
import {
    FileAttachmentsApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new FileAttachmentsApi(configuration);

let id: string; //Attachment ID (default to undefined)
let taskId: string; //Task ID (default to undefined)
let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.attach(
    id,
    taskId,
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | Attachment ID | defaults to undefined|
| **taskId** | [**string**] | Task ID | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**AttachmentInfo**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**404** | File or task not found |  -  |
|**200** | File attached successfully |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **detach**
> AttachmentInfo detach()

Detach a file from its task (keeps file and metadata)

### Example

```typescript
import {
    FileAttachmentsApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new FileAttachmentsApi(configuration);

let id: string; //Attachment ID (default to undefined)
let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.detach(
    id,
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | Attachment ID | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**AttachmentInfo**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | File detached successfully |  -  |
|**404** | File not found |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **download**
> download()

Download a file attachment

### Example

```typescript
import {
    FileAttachmentsApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new FileAttachmentsApi(configuration);

let id: string; //Attachment ID (default to undefined)
let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.download(
    id,
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**string**] | Attachment ID | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

void (empty response body)

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/octet-stream, */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | File downloaded successfully |  -  |
|**404** | File not found |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listForTask**
> Array<AttachmentInfo> listForTask()

Get all attachments for a specific task

### Example

```typescript
import {
    FileAttachmentsApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new FileAttachmentsApi(configuration);

let taskId: string; //Task ID (default to undefined)
let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.listForTask(
    taskId,
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **taskId** | [**string**] | Task ID | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**Array<AttachmentInfo>**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**404** | Task not found |  -  |
|**200** | Attachments retrieved successfully |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listForUser**
> Array<AttachmentInfo> listForUser()

Get all attachments for the current user

### Example

```typescript
import {
    FileAttachmentsApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new FileAttachmentsApi(configuration);

let xUserId: string; // (default to undefined)

const { status, data } = await apiInstance.listForUser(
    xUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **xUserId** | [**string**] |  | defaults to undefined|


### Return type

**Array<AttachmentInfo>**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Attachments retrieved successfully |  -  |
|**404** | User not found |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **upload**
> AttachmentInfo upload()

Upload a file without linking it to a specific task

### Example

```typescript
import {
    FileAttachmentsApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new FileAttachmentsApi(configuration);

let xUserId: string; // (default to undefined)
let file: File; //File to upload (default to undefined)

const { status, data } = await apiInstance.upload(
    xUserId,
    file
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **xUserId** | [**string**] |  | defaults to undefined|
| **file** | [**File**] | File to upload | defaults to undefined|


### Return type

**AttachmentInfo**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**400** | Invalid file or request |  -  |
|**200** | File uploaded successfully |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadForTask**
> AttachmentInfo uploadForTask()

Upload a file and attach it to a specific task

### Example

```typescript
import {
    FileAttachmentsApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new FileAttachmentsApi(configuration);

let taskId: string; //Task ID (default to undefined)
let xUserId: string; // (default to undefined)
let file: File; //File to upload (default to undefined)

const { status, data } = await apiInstance.uploadForTask(
    taskId,
    xUserId,
    file
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **taskId** | [**string**] | Task ID | defaults to undefined|
| **xUserId** | [**string**] |  | defaults to undefined|
| **file** | [**File**] | File to upload | defaults to undefined|


### Return type

**AttachmentInfo**

### Authorization

[XUserIdHeader](../README.md#XUserIdHeader)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**404** | Task not found |  -  |
|**400** | Invalid file or request |  -  |
|**200** | File uploaded and attached successfully |  -  |
|**401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


# DebugControllerApi

All URIs are relative to *http://localhost:8080/api*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**debugAuth**](#debugauth) | **GET** /debug/auth | |
|[**debugPublic**](#debugpublic) | **GET** /debug/public | |

# **debugAuth**
> { [key: string]: object; } debugAuth()


### Example

```typescript
import {
    DebugControllerApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new DebugControllerApi(configuration);

const { status, data } = await apiInstance.debugAuth();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**{ [key: string]: object; }**

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **debugPublic**
> { [key: string]: object; } debugPublic()


### Example

```typescript
import {
    DebugControllerApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new DebugControllerApi(configuration);

const { status, data } = await apiInstance.debugPublic();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**{ [key: string]: object; }**

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


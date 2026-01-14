# HelloControllerApi

All URIs are relative to *http://localhost:8080/api*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**hello**](#hello) | **GET** /hello | |

# **hello**
> string hello()


### Example

```typescript
import {
    HelloControllerApi,
    Configuration
} from '@skysync/api-client';

const configuration = new Configuration();
const apiInstance = new HelloControllerApi(configuration);

const { status, data } = await apiInstance.hello();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**string**

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


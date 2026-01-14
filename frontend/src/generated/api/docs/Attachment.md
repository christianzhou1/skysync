# Attachment


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **string** |  | [optional] [default to undefined]
**userId** | **string** |  | [optional] [default to undefined]
**filename** | **string** |  | [optional] [default to undefined]
**contentType** | **string** |  | [optional] [default to undefined]
**sizeBytes** | **number** |  | [optional] [default to undefined]
**checksumSha256** | **string** |  | [optional] [default to undefined]
**storagePath** | **string** |  | [optional] [default to undefined]
**createdAt** | **string** |  | [optional] [default to undefined]
**updatedAt** | **string** |  | [optional] [default to undefined]
**taskAttachments** | [**Array&lt;TaskAttachment&gt;**](TaskAttachment.md) |  | [optional] [default to undefined]

## Example

```typescript
import { Attachment } from '@skysync/api-client';

const instance: Attachment = {
    id,
    userId,
    filename,
    contentType,
    sizeBytes,
    checksumSha256,
    storagePath,
    createdAt,
    updatedAt,
    taskAttachments,
};
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)

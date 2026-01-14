# TaskDetailInfo


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **string** |  | [optional] [default to undefined]
**title** | **string** |  | [optional] [default to undefined]
**description** | **string** |  | [optional] [default to undefined]
**createdAt** | **string** |  | [optional] [default to undefined]
**dueDate** | **string** |  | [optional] [default to undefined]
**overdue** | **boolean** |  | [optional] [default to undefined]
**daysUntilDue** | **number** |  | [optional] [default to undefined]
**categories** | **Array&lt;string&gt;** |  | [optional] [default to undefined]
**comments** | [**Array&lt;CommentInfo&gt;**](CommentInfo.md) |  | [optional] [default to undefined]
**attachments** | [**Array&lt;AttachmentInfo&gt;**](AttachmentInfo.md) |  | [optional] [default to undefined]
**completed** | **boolean** |  | [optional] [default to undefined]
**deleted** | **boolean** |  | [optional] [default to undefined]

## Example

```typescript
import { TaskDetailInfo } from '@skysync/api-client';

const instance: TaskDetailInfo = {
    id,
    title,
    description,
    createdAt,
    dueDate,
    overdue,
    daysUntilDue,
    categories,
    comments,
    attachments,
    completed,
    deleted,
};
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)

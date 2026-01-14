# Task


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **string** |  | [optional] [default to undefined]
**user** | [**User**](User.md) |  | [optional] [default to undefined]
**title** | **string** |  | [optional] [default to undefined]
**description** | **string** |  | [optional] [default to undefined]
**createdAt** | **string** |  | [optional] [default to undefined]
**dueDate** | **string** |  | [optional] [default to undefined]
**displayOrder** | **number** |  | [optional] [default to undefined]
**parentTask** | [**Task**](Task.md) |  | [optional] [default to undefined]
**subtasks** | [**Array&lt;Task&gt;**](Task.md) |  | [optional] [default to undefined]
**taskAttachments** | [**Array&lt;TaskAttachment&gt;**](TaskAttachment.md) |  | [optional] [default to undefined]
**completed** | **boolean** |  | [optional] [default to undefined]
**deleted** | **boolean** |  | [optional] [default to undefined]

## Example

```typescript
import { Task } from '@skysync/api-client';

const instance: Task = {
    id,
    user,
    title,
    description,
    createdAt,
    dueDate,
    displayOrder,
    parentTask,
    subtasks,
    taskAttachments,
    completed,
    deleted,
};
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)

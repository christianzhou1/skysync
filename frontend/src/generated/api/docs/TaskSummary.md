# TaskSummary


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **string** |  | [optional] [default to undefined]
**title** | **string** |  | [optional] [default to undefined]
**description** | **string** |  | [optional] [default to undefined]
**createdAt** | **string** |  | [optional] [default to undefined]
**dueDate** | **string** |  | [optional] [default to undefined]
**parentTaskId** | **string** |  | [optional] [default to undefined]
**subtasks** | [**Array&lt;TaskSummary&gt;**](TaskSummary.md) |  | [optional] [default to undefined]
**subtaskCount** | **number** |  | [optional] [default to undefined]
**attachmentCount** | **number** |  | [optional] [default to undefined]
**completed** | **boolean** |  | [optional] [default to undefined]
**deleted** | **boolean** |  | [optional] [default to undefined]

## Example

```typescript
import { TaskSummary } from '@skysync/api-client';

const instance: TaskSummary = {
    id,
    title,
    description,
    createdAt,
    dueDate,
    parentTaskId,
    subtasks,
    subtaskCount,
    attachmentCount,
    completed,
    deleted,
};
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)

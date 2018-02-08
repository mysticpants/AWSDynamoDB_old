# AWSDynamoDB

To add this library to your model, add the following lines to the top of your agent code:

```
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSDynamoDB.agent.lib.nut:1.0.0"
```

**Note: [AWSRequestV4](https://github.com/electricimp/AWSRequestV4/) must be loaded.**

This class can be used to perform actions on a DynamoDB table.

## Class Methods

### constructor(region, accessKeyId, secretAccessKey)

All parameters are strings. Access keys can be generated with IAM.

Parameter              |  Type          | Description
---------------------- | -------------- | -----------
**region**             | string         | AWS region
**accessKeyId**        | string         | AWS access key id
**secretAccessKey**    | string         | AWS secret access key id

### Example

```squirrel
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSDynamoDB.agent.lib.nut:1.0.0"

const AWS_DYNAMO_ACCESS_KEY_ID = "YOUR_KEY_ID_HERE";
const AWS_DYNAMO_SECRET_ACCESS_KEY = "YOUR_KEY_HERE";
const AWS_DYNAMO_REGION = "YOUR_REGION_HERE";

db <- AWSDynamoDB(AWS_DYNAMO_REGION, AWS_DYNAMO_ACCESS_KEY_ID, AWS_DYNAMO_SECRET_ACCESS_KEY);
```



### batchGetItem(params, cb)
The `batchGetItem` operation returns the attributes of one or more items from one or more tables. You identify requested items by primary key. For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchGetItem.html

 Parameter             | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | Function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter              | Type              | Required | Description
---------------------  | ----------------- | -------- | -----------
RequestItems           | Table             | Yes      | A map of one or more table names and, for each table, a list of operations to be performed (DeleteRequest or PutRequest)
ReturnConsumedCapacity | String            | No       | Valid values: INDEXES, TOTAL, NONE. INDEXES returns aggregate Consumed Capacity for the operation and ConsumedCapacity for each table and secondary index. TOTAL returns only aggregate ConsumedCapacity. NONE returns no ConsumedCapacity details.

where `res.body` includes the following json encoded parameters

Parameter              | Type                     | Description
---------------------- | ------------------------ | -----------
ConsumedCapacity       | Array of tables          | The capacity units consumed by the entire BatchGetItem operation
Responses              | Table                    | Each object in Responses consists of a table name, along with a map of attribute data consisting of the data type and attribute value.
UnprocessedKeys        | Table                    | A map of tables and their respective keys that were not processed with the current response

### Example
Follows from db.batchWriteItem Example

```squirrel
local getParams = {
    "RequestItems": {
        "testTable2": {
            "Keys": [
                {
                    "deviceId": {"S": imp.configparams.deviceid},
                    "time": {"S": itemTime1}
                },
                {
                    "deviceId": {"S": imp.configparams.deviceid},
                    "time": {"S": itemTime2}
                }
            ]
        }
    }
};
db.batchGetItem(getParams, function(res) {
    local arrayOfReturnedItems = http.jsondecode(res.body).Responses.testTable2;
})
```



### batchWriteItem(params, cb)
The `batchWriteItem` operation puts or deletes multiple items in one or more tables. For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchWriteItem.html

 Parameter             | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter                   | Type                                  | Required | Description
--------------------------- | ------------------------------------- | -------- | -----------
RequestItems                | Table                                 | Yes      | See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_WriteRequest.html
ReturnConsumedCapacity      | String                                | No       | Valid values: INDEXES, TOTAL, NONE. INDEXES returns aggregate Consumed Capacity for the operation and ConsumedCapacity for each table and secondary index. TOTAL returns only aggregate ConsumedCapacity. NONE returns no ConsumedCapacity details.
ReturnItemCollectionMetrics | String                                | No       | Determines whether item collection metrics are returned. If set to SIZE, the response includes statistics about item collections. if set to NONE (default) no statistics are returned

where `res.body` includes the following json encoded parameters

Parameter              | Type            | Description
---------------------- | --------------- | -----------
ConsumedCapacity       | Array of tables | The capacity units consumed by the entire BatchWriteItem operation
ItemCollectionMetrics  | Array of tables | A list of tables that were processed by BatchWriteItem and, for each table, information about any item collections that were affected by individual DeleteItem or PutItem operations
UnprocessedItems       | Array of tables | A map of tables and requests against those tables that were not processed. The UnprocessedItems value is in the same form as RequestItems, so you can provide this value directly to a subsequent BatchGetItem operation

### Example

```squirrel
// writing to an existing table called testTable2
// with key schema seen in create table
local writeParams = {
    "RequestItems": {
        "testTable2": [
            {
                "PutRequest": {
                    "Item": {
                        "deviceId": {
                            "S": imp.configparams.deviceid
                        },
                        "time": {
                            "S": itemTime1
                        },
                        "batchNumber": {
                            "N": "1"
                        }
                    }
                }
            },
            {
                "PutRequest": {
                    "Item": {
                        "deviceId": {
                            "S": imp.configparams.deviceid
                        },
                        "time": {
                            "S": itemTime2
                        },
                        "batchNumber": {
                            "N": "2"
                        }
                    }
                }
            }
        ]
    }
};
db.batchWriteItem(writeParams, function(res) {

    if (res.statuscode >= 200 && res.statuscode < 300) {
        server.log("Batch write successful");
    } else {
        server.log("Batch write unsuccessful");
    }
})
```

### createTable(params, cb)
The `createTable` operation adds a new table to your account. In an AWS account, table names must be unique within each region. For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateTable.html

 Parameter             | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | Function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter                   | Type                                 | Required | Description
--------------------------- | ------------------------------------ | -------- | -----------
AttributeDefinitions        | Array    of  tables                  | Yes      | See http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeDefinition.html
KeySchema                   | Array of  tables                     | Yes      | See http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_KeySchemaElement.html
ProvisionedThroughput       | Table                                | Yes      | See http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ProvisionedThroughput.html
TableName                   | String                               | Yes      | The name of the table to create
GlobalSecondaryIndexes      | Array of tables                      | No       | See http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_GlobalSecondaryIndex.html
LocalSecondaryIndexes       | Array of tables                      | No       | See http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_LocalSecondaryIndex.html
StreamSpecifiation          | Table                                | No       | See  http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_StreamSpecification.html

where `res.body` includes the following json encoded parameters

Parameter               |       Type     | Description
----------------------  | -------------- | -----------
TableDescription        | Table          | Represents the properties of a table. See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TableDescription.html

### Example

```squirrel
local randNum = (1.0 * math.rand() / RAND_MAX) * (1000 + 1);
local tableName = "testTable." + randNum;
local params = {
    "AttributeDefinitions": [
        {
          "AttributeName": "deviceId",
          "AttributeType": "S"
        },
        {
          "AttributeName": "time",
          "AttributeType": "S"
        }
    ],
    "KeySchema": [
        {
            "AttributeName": "deviceId",
            "KeyType": "HASH"
        },
        {
            "AttributeName": "time",
            "KeyType": "RANGE"
        }
    ],
    "ProvisionedThroughput": {
        "ReadCapacityUnits": 5,
        "WriteCapacityUnits": 5
    },
    "TableName": tableName
};
db.createTable(params, function(res) {
    if (res.statuscode >= 200 && res.statuscode < 300) {
        server.log("Table creation successful");
    } else {
        server.log("Table creation unsuccessful");
    }
}.bindenv(this));

```



### deleteItem(params, cb)
Deletes a single item in a table by primary key. For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteItem.html

 Parameter             | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter                   | Type                                       | Required | Description
--------------------------- | ------------------------------------------ | -------- | -----------
Key                         | Table                                      | Yes      | A map of attribute names to AttributeValue objects, representing the primary key of the item to delete
TableName                   | String                                     | Yes      | The name of the table from which to delete the item
ConditionalExpression       | String                                     | No       | A condition that must be satisfied in order for a conditional DeleteItem to succeed
ExpressionAttributeNames    | Table                                      | No       | One or more substitution tokens for attribute names in an expression
ExpressionAttributeValues   | Table                                      | No       | One or more values that can be substituted in an expression
ReturnConsumedCapacity      | String                                     | No       | Valid values: INDEXES, TOTAL, NONE. INDEXES returns aggregate Consumed Capacity for the operation and ConsumedCapacity for each table and secondary index. TOTAL returns only aggregate ConsumedCapacity. NONE returns no ConsumedCapacity details.
ReturnItemCollectionMetrics | String                                     | No       | Determines whether item collection metrics are returned. If set to SIZE, the response includes statistics about item collections. if set to NONE (default) no statistics are returned
ReturnValues                | String                                     | No         | Use ALL_OLD if you want to get the item attributes as they appeared before they were deleted else NONE (default) where nothing is returned

where `res.body` includes the following json encoded parameters

Parameter              | Type           | Description
---------------------- | -------------- | -----------
Attributes             | Table          | The attribute values as they appeared before the PutItem operation. See http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html
ConsumedCapacity       | Table          | The capacity units consumed by the PutItem operation. See http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html
ItemCollectionMetrics  | Table          | Information about item collections, if any, that were affected by the PutItem operation. See http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ItemCollectionMetrics.html

### Example

```squirrel
local tableName = "Your Table Name";
local itemTime = time().tostring();

local deleteParams = {
    "Key": {
        "deviceId": {
            "S": imp.configparams.deviceid
        },
        "time": {
            "S": itemTime
        }
    },
    "TableName": tableName,
};

db.deleteItem(deleteParams, function(res) {

    if (res.statuscode >= 200 && res.statuscode < 300) {
        server.log("Successfully deleted item");
    }
    else {
        server.log("Error: " + res.statuscode);
    }
});
```



### deleteTable(params, cb)
For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteTable.html

 Parameter             | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | Function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter             | Type            | Required | Description
--------------------- | --------------- | -------- | -----------
TableName             | String          | Yes      | The name of the table to delete

where `res.body` can include the following json encoded parameters

 Parameter             | Type           | Description
---------------------- | -------------- | -----------
TableDescription       | Table          | Represents the properties of a table. See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TableDescription.html



### Example

```squirrel
local params = {
    "TableName": tableName
};
db.deleteTable(params, function(res) {

    if (res.statuscode >= 200 && res.statuscode < 300) {
        server.log("Successfully deleted Table");
    }
    else {
        server.log("Error: " + res.statuscode);
    }
});

```



### describeLimits(params, cb)
Returns the current provisioned-capacity limits for your AWS account in a region, both for the region as a whole and for any one DynamoDB table that you create there. For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeLimits.html

 Parameter             | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

where `params` includes no content.

where `res.body` can include the following json encoded parameters

Parameter                    | Type           | Description
---------------------------- | -------------- | -----------
AccountMaxReadCapacityUnits  | Long           | The maximum total read capacity units that your account allows you to provision across all of your tables in this region
AccountMaxWriteCapacityUnits | Long           | The maximum total write capacity units that your account allows you to provision across all of your tables in this region
TableMaxReadCapacityUnits    | Long           | The maximum read capacity units that your account allows you to provision for a new table that you are creating in this region, including the read capacity units provisioned for its global secondary indexes (GSIs)
TableMaxWriteCapacityUnits   | Long           | The maximum write capacity units that your account allows you to provision for a new table that you are creating in this region, including the write capacity units provisioned for its global secondary indexes (GSIs)

### Example

```squirrel

db.describeLimits({}, function(res) {

    if (res.statuscode >= 200 && res.statuscode < 300) {
        server.log("AccountMaxReadCapacityUnits: " + http.jsondecode(res.body).AccountMaxReadCapacityUnits);

    }
    else {
        server.log("Error: " + res.statuscode);
    }
});
```



### describeTable(params, cb)
Returns information about the table, including the current status of the table, when it was created, the primary key schema, and any indexes on the table. For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeTable.html

Parameter              | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter             | Type            | Required | Description
--------------------- | --------------- | -------- | -----------
TableName             | String          | Yes      | The name of the table to describe

where `res.body` includes the following json encoded parameters

Parameter              | Type           | Description
---------------------- | -------------- | -----------
Table                  | Table          | See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TableDescription.html

### Example

```squirrel

local tableName = "YOUR_TABLE_NAME";
local params = {
    "TableName": tableName
};
db.describeTable(params, function(res) {

    server.log("The name of the table described is " + http.jsondecode(res.body).Table.TableName);

});

```



### getItem(params, cb)
The `getItem` operation returns a set of attributes for the item with the given primary key. For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_GetItem.html

Parameter              | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter                   | Type               | Required | Description
--------------------------- | ------------------ | -------- | -----------
Key                         | Table              | Yes      | See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html
TableName                   | String             | Yes      | The name of the table containing the requested item
AttributesToGet             | Array of strings   | No       | See : http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.AttributesToGet.html
ConsistentRead              | Boolean            | No       | If set to true, then the operation uses strongly consistent reads; otherwise, the operation uses eventually consistent reads
ExpressionAttributeNames    | Table              | No       | One or more substitution tokens for attribute names in an expression
ProjectionExpression        | String             | No       |  string that identifies one or more attributes to retrieve from the table. These attributes can include scalars, sets, or elements of a JSON document. The attributes in the expression must be separated by commas
ReturnConsumedCapacity      | String             | No       | Valid values: INDEXES , TOTAL , NONE. INDEXES returns aggregate Consumed Capacity for the operation and ConsumedCapacity for each table and secondary index. TOTAL returns only aggregate ConsumedCapacity. NONE returns no ConsumedCapacity details.

where `res.body` can include the following json encoded parameters

Parameter              | Type           | Description
---------------------- | -------------- | -----------
ConsumedCapacity       | Table          | The capacity units consumed by the GetItem operation. See http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html
Item                   | Table          | A map of attribute names to AttributeValue objects. See http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html

### Example
Follows from getItem
```squirrel
local tableName  = "YOUR_TABLE_NAME";
local itemTime = time().tostring();
local getParams = {
  "Key": {
    "deviceId": {
      "S": imp.configparams.deviceid
    },
    "time": {
        "S": itemTime
    }
  },
  "TableName": tableName,
  "AttributesToGet": [
    "time","status"
  ],
  "ConsistentRead": false
};
db.getItem(getParams, function(res) {

    server.log( "retrieved time: " + http.jsondecode(res.body).Item.time.S);

```



### listTables(params, cb)
Returns an array of table names associated with the current account and endpoint. For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListTables.html

Parameter              | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter                   | Type      | Required | Description
--------------------------- | --------- | -------- | -----------
ExclusiveStartTableName     | String    | No       | The first table name that this operation will evaluate
Limit                       | Integer   | No       | A maximum number of table names to return. If this parameter is not specified, the limit is 100

where `res.body` can include the following json encoded parameters

Parameter              | Type              | Description
---------------------- | ----------------- | -----------
LastEvaluatedTableName | String            | The name of the last table in the current page of results
TableNames             | Array of strings  | The names of the tables associated with the current account at the current endpoint. The maximum size of this array is 100

### Example

```squirrel
local params = {
    "Limit": 10
};

db.listTables(params, function(res) {

    if (res.statuscode >= 200 && res.statuscode < 300) {
        local arrayOfTableNames = http.jsondecode(res.body).TableNames;
    }
    else {
        server.log("error " + res.statuscode);
    }
});

```



### putItem(params, cb)
Creates a new item, or replaces an old item with a new item. For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html

Parameter              | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | Function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter                   | Type               | Required | Description
--------------------------- | ------------------ | -------- | -----------
Item                        | Table              | Yes      | A map of attribute name/value pairs, one for each attribute. Only the primary key attributes are required; you can optionally provide other attribute name-value pairs for the item
TableName                   | String             | Yes      | The name of the table to contain the  item
ConditionalExpression       | String             | No       | A condition that must be satisfied in order for a conditional PutItem to succeed
AttributesToGet             | Array of strings   | No       | See : http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.AttributesToGet.html
ExpressionAttributeNames    | Table              | No       | One or more substitution tokens for attribute names in an expression
ExpressionAttributeValues   | Table              | No       | One or more values that can be substituted in an expression http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html
ReturnConsumedCapacity      | String             | No       | Valid values: INDEXES , TOTAL , NONE. INDEXES returns aggregate Consumed Capacity for the operation and ConsumedCapacity for each table and secondary index. TOTAL returns only aggregate ConsumedCapacity. NONE returns no ConsumedCapacity details
ReturnItemCollectionMetrics | String             | No       | Valid Values: SIZE, NONE. If set to SIZE, the response includes statistics about item collections. if set to NONE no statistics are returned
ReturnValues                | String             | No       | Valid Values ALL_OLD, NONE. ALL_OLD - if PutItem overwrote an attribute name-value pair the content of the old item is returned. NONE - nothing is returned.

where `res.body` includes the following json encoded parameters

Parameter              | Type           | Description
---------------------- | -------------- | -----------
Attributes             | Table          | The attribute values as they appeared before the PutItem operation. See http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html
ConsumedCapacity       | Table          | The capacity units consumed by the PutItem operation. See http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html
ItemCollectionMetrics  | Table          | Information about item collections, if any, that were affected by the PutItem operation. See http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ItemCollectionMetrics.html


### Example

```squirrel
local tableName = "YOUR_TABLE_NAME";
local putParams = {
    "TableName": tableName,
    "Item": {
        "deviceId": {
            "S": imp.configparams.deviceid
        },
        "time": {
            "S": itemTime
        },
        "status": {
            "BOOL": true
        }
    }
};
db.putItem(putParams, function(res) {

    if (res.statuscode == 200) {
        server.log("Successfully put in item");
    }
    else {
        server.log("failed to put item, error: " + res.statuscode);
    }
});
```



### query(params, cb)
A query operation uses the primary key of a table or a secondary index to directly access items from that table or index. For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html

Parameter              | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | Function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter                   | Type               | Required | Description
--------------------------- | -------------------| -------- | -----------
TableName                   | String             | Yes      | The name of the table containing the requested items
AttributesToGet             | Array of strings   | No       | See: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.AttributesToGet.html
ConditionalOperator         | String             | No       | See: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.ConditionalOperator.html
ConsistentRead              | Boolean            | No       | If set to true, then the operation uses strongly consistent reads; otherwise, the operation uses eventually consistent reads
ExclusiveStartKey           | Table              | No       | The primary key of the first item that this operation will evaluate
ExpressionAttributeNames    | Table              | No       | One or more substitution tokens for attribute names in an expression
ExpressionAttributeValues   | Table              | No       | One or more values that can be substituted in an expression
FilterExpression            | String             | No       | See: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Query.html#FilteringResults
IndexName                   | String             | No       | The name of an index to query. This index can be any local secondary index or global secondary index on the table
KeyConditionExpression      | String             | No       | The condition that specifies the key value(s) for items to be retrieved by the Query action.
Limit                       | Integer            | No       | The maximum number of items to evaluate (not necessarily the number of matching items)
ProjectionExpression        | String             | No       | A string that identifies one or more attributes to retrieve from the table
ReturnConsumedCapacity      | String             | No       | Valid values: INDEXES , TOTAL , NONE. INDEXES returns aggregate Consumed Capacity for the operation and ConsumedCapacity for each table and secondary index. TOTAL returns only aggregate ConsumedCapacity. NONE returns no ConsumedCapacity details
ScanIndexForward            | Boolean            | No       | Specifies the order for index traversal: If true (default), the traversal is performed in ascending order; if false, the traversal is performed in descending order
Select                      | String             | No       | The attributes to be returned in the result. You can retrieve all item attributes, specific item attributes, the count of matching items, or in the case of an index, some or all of the attributes projected into the index

where `res.body` includes the following json encoded parameters

Parameter               | Type            | Description
----------------------  | --------------- | -----------
ConsumedCapacity        | Table           | See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html
Count                   | Integer         | The number of items in the response
Items                   | Array of Tables | An array of item attributes that match the query criteria. Each element in this array consists of an attribute name and the value for that attribute
LastEvaluatedKey        | Table           | The primary key of the item where the operation stopped, inclusive of the previous result set. Use this value to start a new operation, excluding this value in the new request
ScannedCount            | Integer         | The number of items evaluated, before any QueryFilter is applied. A high ScannedCount value with few, or no, Count results indicates an inefficient Query operation


### Example

```squirrel
local params = {
    "TableName": tableName,
    "KeyConditionExpression": "deviceId = :deviceId",
    "ExpressionAttributeValues": {
        ":deviceId": {
            "S": imp.configparams.deviceid
        }
    }
};
db.query(params, function(res) {

    if (res.statuscode >= 200 && res.statuscode < 300) {
        server.log("The time stored is: " +  http.jsondecode(res.body).Items[0].time.S);
    }
    else {
        server.log("error: " + res.statuscode);
    }
});

```



### scan(params, cb)
The `scan` operation returns one or more items and item attributes by accessing every item in a Table or a secondary index. For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Scan.html

Parameter              | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | Function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter                   | Type              | Required | Description
--------------------------- | ------------------| -------- | -----------
TableName                   | String            | Yes      | The name of the table containing the requested items; or, if you provide IndexName, the name of the table to which that index belongs
AttributesToGet             | Array of strings  | No       | See: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.AttributesToGet.html
ConditionalOperator         | String            | No       | See: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.ConditionalOperator.html
ConsistentRead              | Boolean           | No       | If set to true, then the operation uses strongly consistent reads; otherwise, the operation uses eventually consistent reads
ExclusiveStartKey           | Table             | No       | The primary key of the first item that this operation will evaluate
ExpressionAttributeNames    | Table             | No       | One or more substitution tokens for attribute names in an expression
ExpressionAttributeValues   | table             | No       | One or more values that can be substituted in an expression
FilterExpression            | String            | No       | One or more values that can be substituted in an expression http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Query.html#FilteringResults
IndexName                   | String            | No       | The name of a secondary index to scan
Limit                       | Integer           | No       | The maximum number of items to evaluate (not necessarily the number of matching items)
ProjectionExpression        | String            | No       | A string that identifies one or more attributes to retrieve from the table
ReturnConsumedCapacity      | String            | No       | Valid values: INDEXES , TOTAL , NONE. INDEXES returns aggregate Consumed Capacity for the operation and ConsumedCapacity for each table and secondary index. TOTAL returns only aggregate ConsumedCapacity. NONE returns no ConsumedCapacity details
Segment                     | Integer           | No       | For a parallel Scan request, Segment identifies an individual segment to be scanned by an application worker
Select                      | String            | No       | The attributes to be returned in the result. You can retrieve all item attributes, specific item attributes, the count of matching items, or in the case of an index, some or all of the attributes projected into the index
TotalSegments               | Integer           | No       | For a parallel Scan request, TotalSegments represents the total number of segments into which the Scan operation will be divided

where `res.body` includes the following json encoded parameters

Parameter              | Type            | Description
---------------------- | --------------- | -----------
ConsumedCapacity       | Table           | See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html
Count                  | Integer         | The number of items in the response
Items                  | Array of Tables | An array of item attributes that match the query criteria. Each element in this array consists of an attribute name and the value for that attribute
LastEvaluatedKey       | Table           | The primary key of the item where the operation stopped, inclusive of the previous result set. Use this value to start a new operation, excluding this value in the new request
ScannedCount           | Integer         | The number of items evaluated, before any QueryFilter is applied. A high ScannedCount value with few, or no, Count results indicates an inefficient Query operation


### Example

```squirrel
local params = {
    "TableName": tableName,
};

db.scan(params, function(res) {

    if (res.statuscode >= 200 && res.statuscode < 300) {
        // returned deviceId from Scan
        // example requires the table created in CreateTable example
        local deviceId = http.jsondecode(res.body).Items[0].deviceId.S;
    }
    else {
        server.log("error: " + res.statuscode);
    }
});
```



### updateItem(params, cb)
For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateItem.html

Parameter              | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | Function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter                   | Type      | Required | Description
--------------------------- | ----------| -------- | -----------
Key                         | Table     | Yes      | The primary key of the item to be updated. See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html
TableName                   | String    | Yes      | The name of the table containing the item to update
AttributesUpdates           | Table     | No       | See : http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LegacyConditionalParameters.AttributeUpdates.html
ConditionalExpression       | String    | No       | A condition that must be satisfied in order for a conditional UpdateItem to succeed
ExpressionAttributeNames    | Table     | No       | One or more substitution tokens for attribute names in an expression
ExpressionAttributeValues   | Table     | No       | One or more values that can be substituted in an expression
ReturnConsumedCapacity      | String    | No       | Valid values: INDEXES , TOTAL , NONE. INDEXES returns aggregate Consumed Capacity for the operation and ConsumedCapacity for each table and secondary index. TOTAL returns only aggregate ConsumedCapacity. NONE returns no ConsumedCapacity details
ReturnItemCollectionMetrics | String    | No       | Determines whether item collection metrics are returned. If set to SIZE, the response includes statistics about item collections. if set to NONE (default) no statistics are returned
ReturnValues                | String    | No       | Use ReturnValues if you want to get the item attributes as they appeared either before or after they were updated. ALL_OLD for all attributes prior to being changed, All_new for all attributes after the change, UPDATED_OLD for all attributes that were changed but returns values prior to change,UPDATED_NEW for all attributes that were changed but returns values after the change   NONE (default) where nothing is returned.
UpdateExpression            | String    | No       | An expression that defines one or more attributes to be updated, the action to be performed on them, and new value(s) for them


where `res.body` includes the following json encoded parameters

Parameter              | Type           | Description
---------------------- | -------------- | -----------
Attributes             | Table          | See : http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_AttributeValue.html
ConsumedCapacity       | Table          | See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ConsumedCapacity.html
ItemCollectionMetrics  | Table          | See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ItemCollectionMetrics.html

### Example
Follows from put item
```squirrel
local updateParams = {
    "Key": {
        "deviceId": {
            "S": imp.configparams.deviceid
        },
        "time": {
            "S": itemTime
        }
    },
    "TableName": tableName,
    "UpdateExpression": "SET newVal = :newVal",
    "ExpressionAttributeValues": {
        ":newVal": {"S":"this is a new value"}
    },
    "ReturnValues": "UPDATED_NEW"
};
db.updateItem(updateParams, function(res) {

    if (res.statuscode >= 200 && res.statuscode < 300) {
        server.log("New attribute was Successfully entered with a value: " + http.jsondecode(res.body).Attributes.newVal.S);
    }
    else {
        server.log("error: " + res.statuscode);
    }
});
```



### updateTable(params, cb)
Modifies the provisioned throughput settings, global secondary indexes, or DynamoDB Streams settings for a given table. For more detail please see:
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTable.html

Parameter              | Type           | Description
---------------------- | -------------- | -----------
**params**             | Table          | Table of parameters (See API Reference)
**cb**                 | Function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter                   | Type             | Required | Description
--------------------------- | -----------------| -------- | -----------
TableName                   | String           | Yes      | The name of the table to be updated
AttributeDefinitions        | Table            | No       | An Array of attributes that describe the key schema for the table and indexes
GlobalSecondaryIndexUpdates | Array of tables  | No       | An array of one or more global secondary indexes for the table. See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTable.html#API_UpdateTable_RequestSyntax
ProvisionedThroughput       | Table            | No       | The new provisioned throughput settings for the specified table or index. See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ProvisionedThroughput.html
StreamSpecification         | Table            | No       | Represents the DynamoDB Streams configuration for the table. See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_StreamSpecification.html

where `res.body` includes the following json encoded parameters

Parameter              | Type           | Description
---------------------- | -------------- | -----------
TableDescription       | Table          | Represents the properties of a table. See: http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TableDescription.html

## Example

```squirrel

local params = {
    "TableName": _tablename,
    "ProvisionedThroughput": {
        "ReadCapacityUnits": 6,
        "WriteCapacityUnits": 6
    }
};
db.updateTable(params, function(res) {

    if (res.statuscode >= 200 && res.statuscode < 300) {
        server.log("New attribute was Successfully entered with a value: " + http.jsondecode(res.body).Attributes.newVal.S);
    }
    else {
        server.log("error: " + res.statuscode);
    }
});
```



#### Response Table
The format of the response table general to all functions

Key                   | Type           | Description
--------------------- | -------------- | -----------
body                  | String         | DynamoDB response in a function specific structure that is json encoded.
statuscode            | Integer        | http status code
headers               | Table          | see headers

where `headers` includes

Key                   | Type           | Description
--------------------- | -------------- | -----------
x-amzn-requestid      | String         | Amazon request id
content-type          | String         | Content type e.g text/XML
date                  | String         | The date and time at which response was sent
content-length        | String         | the length of the content
x-amz-crc32           | String         | Checksum of the UTF-8 encoded bytes in the HTTP response


# License
The AWSDynamoDB library is licensed under the [MIT License](LICENSE).

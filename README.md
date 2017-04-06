# AWSDynamoDB

To add this library to your model, add the following lines to the top of your agent code:

```
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSDynamoDB.class.nut:1.0.0"
```

**Note: [AWSRequestV4](https://github.com/electricimp/AWSRequestV4/) must be loaded.**

This class can be used to perform actions on a DynamoDB table.

## Class Methods

### constructor(region, accessKeyId, secretAccessKey)

All parameters are strings. Access keys can be generated with IAM.

Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**region** | string        | AWS region
**accessKeyId**  | string	      | AWS access key id
**secretAccessKey** | string      | AWS secret access key id

### Example

```squirrel
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSDynamoDB.class.nut:1.0.0"

const ACCESS_KEY_ID = "YOUR_KEY_ID_HERE";
const SECRET_ACCESS_KEY = "YOUR_KEY_HERE";

db <- AWSDynamoDB("us-west-2", ACCESS_KEY_ID, SECRET_ACCESS_KEY);
```
### BatchGetItem(params, cb)
The BatchGetItem operation returns the attributes of one or more items from one or more tables. You identify requested items by primary key.
http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchGetItem.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)


### Example

```squirrel
```

### BatchWriteItem(params, cb)

http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchWriteItem.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Example

```squirrel
```

### CreateTable(params, cb)

http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateTable.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Example

```squirrel
```

### DeleteItem(params, cb)

http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteItem.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Example

```squirrel
```

### DeleteTable(params, cb)

http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteTable.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Example

```squirrel
```

### DescribeLimits(params, cb)

http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeLimits.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Example

```squirrel
```

### DescribeTable(params, cb)

http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeTable.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Example

```squirrel
```

### GetItem(params, cb)

http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_GetItem.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Example

```squirrel
```

### ListTables(params, cb)

http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListTables.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Example

```squirrel
```

### PutItem(params, cb)

http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Example

```squirrel
```

### Query(params, cb)

http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Example

```squirrel
```

### Scan(params, cb)

http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Scan.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Example

```squirrel
```

### UpdateItem(params, cb)

http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateItem.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

### Example

```squirrel
```

### UpdateTable(params, cb)

http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTable.html

 Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**params** | table         | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)


## Example

```squirrel
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSDynamoDB.class.nut:1.0.0"

const ACCESS_KEY_ID = "YOUR_KEY_ID_HERE";
const SECRET_ACCESS_KEY = "YOUR_KEY_HERE";

db <- AWSDynamoDB("us-west-2", ACCESS_KEY_ID, SECRET_ACCESS_KEY);
deviceId <- imp.configparams.deviceid;
time <- time().tostring();

// PutItem
local putParams = {
	"TableName": "testTable",
	"Item": {
		"deviceId": {
			"S": deviceId
		},
		"time": {
			"S": time
		}
	}
};

db.PutItem(putParams, function(response) {
    server.log(response.statuscode + ": " + response.body);
});

// GetItem
local getParams = {
    "TableName": "testTable",
    "Key": {
        "deviceId": {
            "S": deviceId
        },
        "time": {
            "S": time
        }
    }
};

db.GetItem(getParams, function(response) {
    server.log("Data:" + http.jsonencode(response.body.Item));    
});
```

# License

The AWSDynamoDB library is licensed under the [MIT License](https://github.com/electricimp/thethingsapi/tree/master/LICENSE).

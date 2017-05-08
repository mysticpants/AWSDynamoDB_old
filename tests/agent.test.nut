// Enter your AWS keys here
const AWS_DYNAMO_ACCESS_KEY_ID = "YOUR_KEY_ID_HERE";
const AWS_DYNAMO_SECRET_ACCESS_KEY = "YOUR_KEY_HERE";
const AWS_DYNAMO_REGION = "YOUR_REGION_HERE";

// http status codes
const AWS_TEST_HTTP_RESPONSE_SUCCESS = 200;
const AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND = 300;
const AWS_TEST_HTTP_RESPONSE_FORBIDDEN = 403;
const AWS_TEST_HTTP_RESPONSE_NOT_FOUND = 404;
const AWS_TEST_HTTP_RESPONSE_BAD_REQUEST = 400;

// messages
const AWS_TEST_UPDATE_VALUE = "this is a new value";
const AWS_TEST_FAKE_TABLE_NAME = "garbage";
const AWS_TEST_FAKE_TIME = 0;

// aws response error messages
const AWS_ERROR_CONVERT_TO_STRING = "class com.amazon.coral.value.json.numbers.TruncatingBigNumber can not be converted to an String";
const AWS_ERROR_REOSOURCE_NOT_FOUND = "Requested resource not found";
const AWS_ERROR_PARAMETER_NOT_PRESENT = "The parameter 'TableName' is required but was not present in the request";
const AWS_ERROR_LIMIT_100 = "1 validation error detected: Value '200' at 'limit' failed to satisfy constraint: Member must have value less than or equal to 100";

// info messages
const AWS_TEST_WAITING_FOR_TABLE = "Table not created yet. Waiting 5 seconds before starting tests..."

class DynamoDBTest extends ImpTestCase {
    db = null;
    _tablename = null;
    _KeySchema = null;
    _AttributeDefinitions = null;
    _ProvisionedThroughput = null;



    // instantiates the class (AWSDynamoDB) as db
    // Creates a table named testTable.randNum
    function setUp() {
        // Parameters to set up categories for a table
        _KeySchema = [{
            "AttributeName": "deviceId",
            "KeyType": "HASH"
        }, {
            "AttributeName": "time",
            "KeyType": "RANGE"
        }];
        _AttributeDefinitions = [{
            "AttributeName": "deviceId",
            "AttributeType": "S"
        }, {
            "AttributeName": "time",
            "AttributeType": "S"
        }];
        _ProvisionedThroughput = {
            "ReadCapacityUnits": 5,
            "WriteCapacityUnits": 5
        };

        return Promise(function(resolve, reject) {

            // class initialisation
            db = AWSDynamoDB(AWS_DYNAMO_REGION, AWS_DYNAMO_ACCESS_KEY_ID, AWS_DYNAMO_SECRET_ACCESS_KEY);

            local randNum = (1.0 * math.rand() / RAND_MAX) * (1000 + 1);
            _tablename = "testTable." + randNum;
            local params = {
                "AttributeDefinitions": _AttributeDefinitions,
                "KeySchema": _KeySchema,
                "ProvisionedThroughput": _ProvisionedThroughput,
                "TableName": _tablename
            };
            // Create a table with random name per test testTable.randNum
            db.CreateTable(params, function(res) {

                // check status code indication successful creation
                if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                    local describeParams = {
                        "TableName": _tablename
                    };
                    // wait for the table to finish being created
                    // important as toomany request to awd db will cause errors
                    checkTable(describeParams, function(result) {

                        if (typeof result == "bool" && result == true) {
                            resolve("Running #{__FILE__}");
                        } else {
                            reject(result);
                        }
                    }.bindenv(this));
                } else {
                    reject("Failed to create table during setup of #{__FILE__}. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                }
            }.bindenv(this));
        }.bindenv(this));
    }



    // To be called by the setup() method
    // waits until table is active e.g finished creating then calls cb
    function checkTable(params, cb) {

        db.DescribeTable(params, function(res) {

            if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                if (http.jsondecode(res.body).Table.TableStatus == "ACTIVE") {
                    cb(true);
                } else {
                    this.info(AWS_TEST_WAITING_FOR_TABLE);
                    imp.wakeup(5, function() {
                        checkTable(params, cb);
                    }.bindenv(this));
                }
            } else {
                local msg = "Failed to describe table during setup of #{__FILE__}. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message;
                cb(msg);
            }
        }.bindenv(this));
    }



    // Checking that putting an item in a non-existent table returns
    // a http status 400 and the correct error message reveived from aws
    function testFailPutItem() {

        local params = {
            "TableName": AWS_TEST_FAKE_TABLE_NAME,
            "Item": {
                "deviceId": {
                    "S": imp.configparams.deviceid
                },
                "time": {
                    "S": time().tostring()
                },
                "status": {
                    "BOOL": true
                }
            }
        };
        return Promise(function(resolve, reject) {

            db.PutItem(params, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, "Actual status: " + res.statuscode);
                    this.assertTrue(AWS_ERROR_REOSOURCE_NOT_FOUND == http.jsondecode(res.body).message, http.jsondecode(res.body).message)
                    resolve("did not put item in non existent table");
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }



    // Checking that putting a number in as string throws an error
    // a http status 400 and the correct error message from aws
    function testFailGeItem() {
        local getParams = {
            "Key": {
                "deviceId": {
                    "S": imp.configparams.deviceid
                },
                "time": {
                    "S": AWS_TEST_FAKE_TIME
                }
            },
            "TableName": _tablename,
            "AttributesToGet": [
                "time", "status"
            ],
            "ConsistentRead": false
        };
        return Promise(function(resolve, reject) {

            db.GetItem(getParams, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, "Actual status: " + res.statuscode);
                    this.assertTrue(http.jsondecode(res.body).Message == AWS_ERROR_CONVERT_TO_STRING)
                    resolve("did not put item in non existent table");
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }


    // Test putting a item in a table then retrieving it via a get
    // specifically checking the time at which the item is put in is stored
    // and that we are retrieving it via a get
    function testGetItem() {

        local itemTime = time().tostring();
        local putParams = {
            "TableName": _tablename,
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
        local getParams = {
            "Key": {
                "deviceId": {
                    "S": imp.configparams.deviceid
                },
                "time": {
                    "S": itemTime
                }
            },
            "TableName": _tablename,
            "AttributesToGet": [
                "time", "status"
            ],
            "ConsistentRead": false
        };

        return Promise(function(resolve, reject) {

            db.PutItem(putParams, function(res) {
                if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {

                    db.GetItem(getParams, function(res) {
                        if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                            try {
                                this.assertTrue(itemTime == http.jsondecode(res.body).Item.time.S, "retrieved time: " + http.jsondecode(res.body).Item.time.S + "sent time: " + itemTime);
                                resolve("Successfully got item");
                            } catch (e) {
                                reject(e);
                            }

                        } else {
                            reject("Failed to get item. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                        }
                    }.bindenv(this));
                } else {
                    reject("Failed to put item (prior to getting). Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                }
            }.bindenv(this));

        }.bindenv(this));
    }



    // Add a new item to an existing table
    // Check that response contains the correct value added in the returned Attributes section
    // Should only return updated Items
    function testUpdateItem() {

        local itemTime = time().tostring();
        local putParams = {
            "TableName": _tablename,
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
        local updateParams = {
            "Key": {
                "deviceId": {
                    "S": imp.configparams.deviceid
                },
                "time": {
                    "S": itemTime
                }
            },
            "TableName": _tablename,
            "UpdateExpression": "SET newVal = :newVal",
            "ExpressionAttributeValues": {
                ":newVal": { "S": AWS_TEST_UPDATE_VALUE }
            },
            "ReturnValues": "UPDATED_NEW"
        };
        return Promise(function(resolve, reject) {

            db.PutItem(putParams, function(res) {
                if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                    db.UpdateItem(updateParams, function(res) {

                        if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                            try {
                                this.assertTrue(http.jsondecode(res.body).Attributes.len() == 1, "Actual number of attributes altered: " + http.jsondecode(res.body).Attributes.len());
                                this.assertTrue(AWS_TEST_UPDATE_VALUE == http.jsondecode(res.body).Attributes.newVal.S, "the actual updated value is: " + http.jsondecode(res.body).Attributes.newVal.S);
                                resolve("Successfully Updated Items");
                            } catch (e) {
                                reject(e);
                            }

                        } else {
                            reject("Failed to update item. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                        }
                    }.bindenv(this));
                } else {
                    reject("Failed to put item (prior to updating). Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                }
            }.bindenv(this));
        }.bindenv(this));
    }



    // Deletes an item
    // checks the http response code indicating a successful response
    function testDeleteItem() {

        local itemTime = time().tostring();
        local putParams = {
            "TableName": _tablename,
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
        local deleteParams = {
            "Key": {
                "deviceId": {
                    "S": imp.configparams.deviceid
                },
                "time": {
                    "S": itemTime
                }
            },
            "TableName": _tablename,
            "ReturnValues": "ALL_OLD"
        };
        return Promise(function(resolve, reject) {

            db.PutItem(putParams, function(res) {

                if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                    db.DeleteItem(deleteParams, function(res) {

                        try {
                            this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual statuscode is " + res.statuscode);
                            resolve("Successfully Deleted Item");
                        } catch (e) {
                            reject(e);
                        }

                    }.bindenv(this));
                } else {
                    reject("Failed to put item (prior to deleting). Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                }
            }.bindenv(this));
        }.bindenv(this));
    }



    // create a specific table called testTable wait for it to be created.
    // Then write a batch message to it.
    // Wait for the table to be updated. Then check if updates went through via scan
    function testBatchWriteItem() {
        local createParams = {
            "AttributeDefinitions": _AttributeDefinitions,
            "KeySchema": _KeySchema,
            "ProvisionedThroughput": _ProvisionedThroughput,
            "TableName": "testTable"
        };
        local writeParams = {
            "RequestItems": {
                "testTable": [{
                    "PutRequest": {
                        "Item": {
                            "deviceId": {
                                "S": imp.configparams.deviceid
                            },
                            "time": {
                                "S": time().tostring()
                            },
                            "batchNumber": {
                                "N": "1"
                            }
                        }
                    }
                }]
            }
        };

        return Promise(function(resolve, reject) {

            db.CreateTable(createParams, function(res) {

                checkTable({ "TableName": "testTable" }, function(res) {

                    db.BatchWriteItem(writeParams, function(res) {

                        checkTableUpdated({ "TableName": "testTable" }, function(res) {

                            db.Scan({ "TableName": "testTable" }, function(res) {

                                try {
                                    this.assertTrue(http.jsondecode(res.body).Items[0].batchNumber.N == "1", "Batch number incorrect")

                                    afterCreateTable("testTable", function(res) {
                                        resolve("Successfully wrote a batch of items");
                                    });

                                } catch (e) {
                                    reject(e);
                                }


                            }.bindenv(this));
                        }.bindenv(this));
                    }.bindenv(this));
                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this));
    }



    // create a specific table called testTable2 wait for it to be created.
    // Then write a batch message to it.
    // Use the BatchGetItem and test if the correct items are returned
    // Note order of insertion isn't consistent
    function testBatchGetItem() {

        local createParams = {
            "AttributeDefinitions": _AttributeDefinitions,
            "KeySchema": _KeySchema,
            "ProvisionedThroughput": _ProvisionedThroughput,
            "TableName": "testTable2"
        };
        local itemTime1 = time().tostring();
        local itemTime2 = (time() + 1).tostring();
        local writeParams = {
            "RequestItems": {
                "testTable2": [{
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
                }, {
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
                }]
            }
        };
        local getParams = {
            "RequestItems": {
                "testTable2": {
                    "Keys": [{
                        "deviceId": { "S": imp.configparams.deviceid },
                        "time": { "S": itemTime1 }
                    }, {
                        "deviceId": { "S": imp.configparams.deviceid },
                        "time": { "S": itemTime2 }
                    }]
                }
            }
        };
        return Promise(function(resolve, reject) {

            db.CreateTable(createParams, function(res) {

                checkTable({ "TableName": "testTable2" }, function(res) {

                    db.BatchWriteItem(writeParams, function(res) {

                        checkTableUpdated({ "TableName": "testTable2" }, function(res) {

                            if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                                db.BatchGetItem(getParams, function(res) {

                                    if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                                        local check = http.jsondecode(res.body).Responses;

                                        afterCreateTable("testTable2", function(res) {

                                            try {
                                                foreach (item in check.testTable2) {
                                                    if (item.batchNumber.N == "1") {
                                                        this.assertTrue(item.time.S == itemTime1, "batch 1 time does " + itemTime1 + " not match " + item.time.S);
                                                    } else {
                                                        this.assertTrue(item.time.S == itemTime2, "batch 1 time does " + itemTime2 + " not match " + item.time.S);
                                                    }
                                                }
                                                resolve("Successfully got a batch of items");
                                            } catch (e) {
                                                reject(e);
                                            }
                                        }.bindenv(this));
                                    } else {
                                        reject("Failed to get a batch of items. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                                    }
                                }.bindenv(this));
                            } else {
                                reject("Failed to write a batch of items (prior to getting). Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                            }
                        }.bindenv(this));

                    }.bindenv(this));
                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this));
    }



    // Test create a table, checks that the tablename, keyschema and
    // attribute definitions of created table match
    function testCreateTable() {

        local randNum = (1.0 * math.rand() / RAND_MAX) * (1000 + 1);
        local tableName = "testTable." + randNum;
        local params = {
            "AttributeDefinitions": _AttributeDefinitions,
            "KeySchema": _KeySchema,
            "ProvisionedThroughput": _ProvisionedThroughput,
            "TableName": tableName
        };
        return Promise(function(resolve, reject) {

            db.CreateTable(params, function(res) {

                if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                    try {
                        this.assertTrue(http.jsondecode(res.body).TableDescription.TableName == tableName, "Actual TableName: " + http.jsondecode(res.body).TableDescription.TableName);
                        this.assertDeepEqual(_AttributeDefinitions, http.jsondecode(res.body).TableDescription.AttributeDefinitions, "AttributeDefinitions of created table does match what was intended");
                        this.assertDeepEqual(_KeySchema, http.jsondecode(res.body).TableDescription.KeySchema, "keyschema of created table does match what was intended");
                        afterCreateTable(tableName, function(res) {
                            resolve("Successfully created a table");
                        });

                    } catch (e) {
                        reject(e);
                    }

                } else {
                    reject("Failed to create a table. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                }
            }.bindenv(this));
        }.bindenv(this));
    }



    // Method to cleanup after testCreateTable()
    function afterCreateTable(tableName, cb) {
        local params = {
            "TableName": tableName
        };

        db.DescribeTable(params, function(res) {

            if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                if (http.jsondecode(res.body).Table.TableStatus == "ACTIVE") {
                    db.DeleteTable(params, function(res) {

                        if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                            this.info("Cleaned up after testCreateTable().");
                            cb(true);
                        } else {
                            this.info("Failed to clean up after testCreateTable(). Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                        }
                    }.bindenv(this));
                } else {
                    this.info("Table not created yet. Waiting 5 seconds before cleaning up after testCreateTable()...");
                    imp.wakeup(5, function() {

                        afterCreateTable(tableName, cb);
                    }.bindenv(this));
                }
            } else {
                this.info("Failed to clean up after testCreateTable(). Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
            }
        }.bindenv(this));
    }



    // Obtains a description of a table checks that the returned tableName is the one that we were checking for
    // also check for keyschema and AttributeDefinitions
    function testDescribeTable() {

        return Promise(function(resolve, reject) {

            db.DescribeTable({ "TableName": _tablename }, function(res) {

                if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                    try {
                        this.assertTrue(http.jsondecode(res.body).Table.TableName == _tablename, "the wrong table described was described");
                        this.assertDeepEqual(_AttributeDefinitions, http.jsondecode(res.body).Table.AttributeDefinitions, "AttributeDefinitions of created table does match what was intended");
                        this.assertDeepEqual(_KeySchema, http.jsondecode(res.body).Table.KeySchema, "keyschema of created table does match what was intended");
                        resolve("Successfully described table.");
                    } catch (e) {
                        reject(e);
                    }
                } else {
                    reject("Failed to describe a table. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                }
            }.bindenv(this));
        }.bindenv(this));
    }



    // Try to update table without the tablename parameter
    function testFailUpdateTable() {
        local params = {
            "ProvisionedThroughput": {
                "ReadCapacityUnits": 6,
                "WriteCapacityUnits": 6
            }
        };
        return Promise(function(resolve, reject) {

            db.UpdateTable(params, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, res.statuscode)
                    this.assertTrue(http.jsondecode(res.body).message == AWS_ERROR_PARAMETER_NOT_PRESENT, http.jsondecode(res.body).message)
                    resolve();
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }



    // Test the update table function changes the tables
    // describes the table once it is updated to see if changes were made
    function testUpdateTable() {
        local params = {
            "TableName": _tablename,
            "ProvisionedThroughput": {
                "ReadCapacityUnits": 6,
                "WriteCapacityUnits": 6
            }

        };
        return Promise(function(resolve, reject) {

            db.UpdateTable(params, function(res) {

                if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {

                    checkTableUpdated({ "TableName": _tablename }, function(res) {
                        if (typeof(res) == "string") {
                            reject(res);
                        } else {
                            try {
                                this.assertTrue(http.jsondecode(res.body).Table.ProvisionedThroughput.ReadCapacityUnits == 6, "incorrect ReadCapacityUnits");
                                this.assertTrue(http.jsondecode(res.body).Table.ProvisionedThroughput.WriteCapacityUnits == 6, "incorrect WriteCapacityUnits");
                                resolve("Successfully updated table.");
                            } catch (e) {
                                reject(e);
                            }
                        }
                    });

                } else {
                    reject("Failed to update a table. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                }

            }.bindenv(this));
        }.bindenv(this));
    }



    // To be called by the UpdateTable method, checks when a table has finished
    // updating its contained data
    function checkTableUpdated(params, cb) {

        db.DescribeTable(params, function(res) {

            if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                if (http.jsondecode(res.body).Table.TableStatus == "ACTIVE") {
                    cb(res);
                } else {
                    this.info("table not yet updated");
                    imp.wakeup(5, function() {

                        checkTableUpdated(params, cb);
                    }.bindenv(this));
                }
            } else {
                local msg = "Failed to describe table . Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message;
                cb(msg);
            }
        }.bindenv(this));
    }




    // creates a table then deletes it
    // checks for a 200 response
    // checks that the status of the table is deleting
    // waits for the table to no longer be findable hence deleted
    function testDeleteTable() {

        local randNum = (1.0 * math.rand() / RAND_MAX) * (1000 + 1);
        local tableName = "testTable." + randNum;
        local createParams = {
            "AttributeDefinitions": [{
                "AttributeName": "deviceId",
                "AttributeType": "S"
            }, {
                "AttributeName": "time",
                "AttributeType": "S"
            }],
            "KeySchema": [{
                "AttributeName": "deviceId",
                "KeyType": "HASH"
            }, {
                "AttributeName": "time",
                "KeyType": "RANGE"
            }],
            "ProvisionedThroughput": {
                "ReadCapacityUnits": 5,
                "WriteCapacityUnits": 5
            },
            "TableName": tableName
        };
        local deleteParams = {
            "TableName": tableName
        };
        return Promise(function(resolve, reject) {

            db.CreateTable(createParams, function(res) {

                if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {

                    describeAndDeleteTable(deleteParams, function(result) {

                        if (typeof result == "bool" && result == true) {

                            checkTableDeleted({ "TableName": tableName }, function(res) {

                                local compareString = "Failed to describe table . Statuscode: 400. Message: Requested resource not found: Table: " + tableName + " not found";
                                this.assertTrue(res == compareString, "response: " + res);
                                resolve("Deleted Table Successfully");
                            });

                        } else {
                            reject(result);
                        }
                    }.bindenv(this));

                } else {
                    reject("Failed to create a table (prior to deleting). Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                }
            }.bindenv(this));
        }.bindenv(this));
    }



    // To be called by the delete table test, determines when deletion is complete
    function checkTableDeleted(params, cb) {

        db.DescribeTable(params, function(res) {

            if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                if (http.jsondecode(res.body).Table.TableStatus == "DELETING") {
                    this.info("table not yet updated");
                    imp.wakeup(5, function() {

                        checkTableUpdated(params, cb);
                    }.bindenv(this));

                } else {
                    reject("NOT DELETED");
                }
            } else {
                cb(res);
            }
        }.bindenv(this));
    }



    // To be called by the testDeleteTable() testing method
    function describeAndDeleteTable(params, cb) {

        db.DescribeTable(params, function(res) {

            if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                if (http.jsondecode(res.body).Table.TableStatus == "ACTIVE") {
                    db.DeleteTable(params, function(res) {

                        if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                            cb(true);
                        } else {
                            local msg = "Failed to delete a table. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message;
                            cb(msg);
                        }
                    }.bindenv(this));
                } else {
                    this.info("Table not created yet. Waiting 5 seconds before deleting...");
                    imp.wakeup(5, function() {

                        describeAndDeleteTable(params, cb);
                    }.bindenv(this));
                }
            } else {
                local msg = "Failed to describe a table (prior to deleting). Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message;
                cb(msg);
            }
        }.bindenv(this));
    }



    // tests the DescribeLimits function returns values for the provisioned
    // capacity limits < 100
    function testDescribeLimits() {

        return Promise(function(resolve, reject) {

            db.DescribeLimits({}, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "statuscode: " + res.statuscode);
                    this.assertTrue(http.jsondecode(res.body).TableMaxWriteCapacityUnits != null);
                    this.assertTrue(http.jsondecode(res.body).AccountMaxReadCapacityUnits != null);
                    this.assertTrue(http.jsondecode(res.body).TableMaxReadCapacityUnits != null);
                    this.assertTrue(http.jsondecode(res.body).AccountMaxWriteCapacityUnits != null);
                    resolve();
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));
        }.bindenv(this));
    }



    // return an array of TableNames
    // checks for _tablename is listed
    function testListTables() {

        local params = {
            "Limit": 10
        };
        return Promise(function(resolve, reject) {

            db.ListTables(params, function(res) {

                local arrayTableNames = http.jsondecode(res.body).TableNames;
                if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                    try {
                        for (local i = 0; i < arrayTableNames.len(); i++) {
                            if (arrayTableNames[i] == _tablename) {
                                this.assertTrue(true);
                                return resolve("Successfully listed tables.");
                            }
                        }
                    } catch (e) {
                        reject(e);
                    }
                } else {
                    reject("Failed to list tables. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                }
            }.bindenv(this));
        }.bindenv(this));
    }



    // return an array of TableNames
    // Limit is maximum of 100
    function testFailListTables() {

        local params = {
            "Limit": 200
        };
        return Promise(function(resolve, reject) {

            db.ListTables(params, function(res) {

                try {
                    this.assertTrue(http.jsondecode(res.body).message == AWS_ERROR_LIMIT_100, http.jsondecode(res.body).message);
                    resolve("Limit of 100");
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));
        }.bindenv(this));
    }



    // tests a query and checks that the retrieved values were aligned
    function testQuery() {
        return Promise(function(resolve, reject) {

            local params = {
                "TableName": _tablename,
                "KeyConditionExpression": "deviceId = :deviceId",
                "ExpressionAttributeValues": {
                    ":deviceId": {
                        "S": imp.configparams.deviceid
                    }
                }
            };
            db.Query(params, function(res) {

                if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                    try {
                        this.assertTrue(http.jsondecode(res.body).Items[0].deviceId.S == imp.configparams.deviceid, "wrong device id");
                        resolve("Successfully queried a table.");
                    } catch (e) {
                        reject(e);
                    }

                } else {
                    reject("Failed to query a table. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                }
            }.bindenv(this));
        }.bindenv(this));
    }



    // test the scan function returns both the correct value of deviceId
    // and only returns a single item as the table should only have 1 item.
    function testScan() {

        local params = {
            "TableName": _tablename,
        };
        return Promise(function(resolve, reject) {

            db.Scan(params, function(res) {

                if (res.statuscode >= AWS_TEST_HTTP_RESPONSE_SUCCESS && res.statuscode < AWS_TEST_HTTP_RESPONSE_SUCCESS_UPPER_BOUND) {
                    try {
                        this.assertTrue(http.jsondecode(res.body).Items[0].deviceId.S == imp.configparams.deviceid, "wrong device id");
                        this.assertTrue(http.jsondecode(res.body).ScannedCount == 1, "unexpected number of items");
                        resolve("Successfully scanned a table.");
                    } catch (e) {
                        reject(e);
                    }
                } else {
                    reject("Failed to scan a table. Statuscode: " + res.statuscode + ". Message: " + http.jsondecode(res.body).message);
                }
            }.bindenv(this));
        }.bindenv(this));
    }



    // deletes the table used throughout the tests
    function tearDown() {

        return Promise(function(resolve, reject) {

            local params = {
                "TableName": _tablename
            };
            describeAndDeleteTable(params, function(result) {

                if (typeof result == "bool" && result == true) {
                    resolve("Finished testing and cleaned up after #{__FILE__}");
                } else {
                    reject("Finished testing but failed to clean up after #{__FILE__}");
                }
            }.bindenv(this));
        }.bindenv(this));
    }
}

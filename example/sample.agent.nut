// MIT License
//
// Copyright 2018 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSDynamoDB.agent.lib.nut:1.0.0"


// Enter Your AWS details here
const AWS_DYNAMO_ACCESS_KEY_ID = "YOUR_KEY_ID_HERE";
const AWS_DYNAMO_SECRET_ACCESS_KEY = "YOUR_KEY_HERE";
const AWS_DYNAMO_REGION = "YOUR_REGION_HERE";

// Supporting functions
// informs when table finish being created
function checkTable(params, cb) {

    db.DescribeTable(params, function(res) {

        if (res.statuscode >= 200 && res.statuscode < 300) {
            if (http.jsondecode(res.body).Table.TableStatus == "ACTIVE") {
                cb(true);
            } else {
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


db <- AWSDynamoDB(AWS_DYNAMO_REGION, AWS_DYNAMO_ACCESS_KEY_ID, AWS_DYNAMO_SECRET_ACCESS_KEY);
local randNum = (1.0 * math.rand() / RAND_MAX) * (1000 + 1);
local tableName = "testTable." + randNum;
deviceid <- imp.configparams.deviceid;
time <- time().tostring();

local params = {
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
    "TableName": "test"
};

// PutItem parameters
local putParams = {
    "TableName": "test",
    "Item": {
        "deviceId": {
            "S": imp.configparams.deviceid
        },
        "time": {
            "S": time
        },
        "status": {
            "BOOL": true
        }
    }
};

// GetItem parameters
local getParams = {
    "Key": {
        "deviceId": {
            "S": imp.configparams.deviceid
        },
        "time": {
            "S": time
        }
    },
    "TableName": "test",
    "AttributesToGet": [
        "time"
    ],
    "ConsistentRead": false
};


// Runtime
db.CreateTable(params, function(res) {

    if (res.statuscode >= 200 && res.statuscode < 300) {
        // check table is created
        checkTable({ "TableName": "test" }, function(res) {

            server.log("Table creation successful");
            // puts an item in the table
            db.PutItem(putParams, function(res) {

                server.log("Item put in table Successfully");
                // waits until item is put table
                checkTable({ "TableName": "test" }, function(res) {

                    db.GetItem(getParams, function(res) {

                        server.log("retrieveval successful retrieved time: " + http.jsondecode(res.body).Item.time.S);
                        db.DeleteTable({ "TableName": "test" }, function(res) {

                            server.log("Successfully deleted table");
                        });
                    });
                });
            });
        });

    } else {
        server.log("Table creation unsuccessful");
    }
}.bindenv(this));

// MIT License
//
// Copyright 2017 Electric Imp
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

class AWSDynamoDB {

    static VERSION  = "1.0.0";
    static SERVICE = "dynamodb";
    static TARGET_PREFIX = "DynamoDB_20120810";

    // the aws request object
    _awsRequest = null;


    // 	Parameters:
    //	 region				AWS region
    //   accessKeyId		AWS access key Id
    //   secretAccessKey    AWS secret access key
    constructor(region, accessKeyId, secretAccessKey) {

        if ("AWSRequestV4" in getroottable()) {
            _awsRequest = AWSRequestV4(SERVICE, region, accessKeyId, secretAccessKey);
        } else {
            throw ("This class requires AWSRequestV4 - please make sure it is loaded.");
        }
    }


    //	The BatchGetItem operation returns the attributes of one or more items from one or more tables
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //						from aws
    function BatchGetItem(params, cb) {
        local headers = { "X-Amz-Target": format("%s.BatchGetItem", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }


    //	The BatchWriteItem operation puts or deletes multiple items in one or more tables
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function BatchWriteItem(params, cb) {
        local headers = { "X-Amz-Target": format("%s.BatchWriteItem", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }



    //	The CreateTable operation adds a new table to your account
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function CreateTable(params, cb) {
        local headers = { "X-Amz-Target": format("%s.CreateTable", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }


    //	Deletes a single item in a table by primary key
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws

    function DeleteItem(params, cb) {
        local headers = { "X-Amz-Target": format("%s.DeleteItem", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    //	Deletes a table
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function DeleteTable(params, cb) {
        local headers = { "X-Amz-Target": format("%s.DeleteTable", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }



    //	Returns the current provisioned-capacity limits for your AWS account in
    //	a region, both for the region as a whole and for any one DynamoDB table
    //	that you create there
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function DescribeLimits(params, cb) {
        local headers = { "X-Amz-Target": format("%s.DescribeLimits", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }


    //	Returns information about the table, including the current status of the
    //  table, when it was created, the primary key schema, and any indexes on
    //  the table
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function DescribeTable(params, cb) {
        local headers = { "X-Amz-Target": format("%s.DescribeTable", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }


    // The GetItem operation returns a set of attributes for the item with the
    // given primary key
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function GetItem(params, cb) {
        local headers = { "X-Amz-Target": format("%s.GetItem", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }


    // Returns an array of table names associated with the current account and endpoint
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function ListTables(params, cb) {
        local headers = { "X-Amz-Target": format("%s.ListTables", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }


    // Creates a new item, or replaces an old item with a new item
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function PutItem(params, cb) {
        local headers = { "X-Amz-Target": format("%s.PutItem", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }


    //  A Query operation uses the primary key of a table or a secondary index
    //  to directly access items from that table or index
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function Query(params, cb) {
        local headers = { "X-Amz-Target": format("%s.Query", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    //  The Scan operation returns one or more items and item attributes by
    //  accessing every item in a Table or a secondary index
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function Scan(params, cb) {
        local headers = { "X-Amz-Target": format("%s.Scan", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }


    //  Edits an existing item's attributes, or adds a new item to the table if
    //  it does not already exist
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function UpdateItem(params, cb) {
        local headers = { "X-Amz-Target": format("%s.UpdateItem", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }
    
    
    //  Modifies the provisioned throughput settings, global secondary indexes,
    //  or DynamoDB Streams settings for a given table
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function UpdateTable(params, cb) {
        local headers = { "X-Amz-Target": format("%s.UpdateTable", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

}

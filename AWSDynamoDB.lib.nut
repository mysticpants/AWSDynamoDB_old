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

    _awsRequest = null;

    ////////////////////////////////////////////////////////////////////////////
    // @param {string} region - \
    // @param {string} accessKeyId
    // @param {string} secretAccessKey
    ////////////////////////////////////////////////////////////////////////////
    constructor(region, accessKeyId, secretAccessKey) {
        if ("AWSRequestV4" in getroottable()) {
            _awsRequest = AWSRequestV4(SERVICE, region, accessKeyId, secretAccessKey);
        } else {
            throw ("This class requires AWSRequestV4 - please make sure it is loaded.");
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
    ////////////////////////////////////////////////////////////////////////////
    function BatchGetItem(params, cb) {
        local headers = { "X-Amz-Target": format("%s.BatchGetItem", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
    ////////////////////////////////////////////////////////////////////////////
    function BatchWriteItem(params, cb) {
        local headers = { "X-Amz-Target": format("%s.BatchWriteItem", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
    ////////////////////////////////////////////////////////////////////////////
    function CreateTable(params, cb) {
        local headers = { "X-Amz-Target": format("%s.CreateTable", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
    ////////////////////////////////////////////////////////////////////////////
    function DeleteItem(params, cb) {
        local headers = { "X-Amz-Target": format("%s.DeleteItem", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
    ////////////////////////////////////////////////////////////////////////////
    function DeleteTable(params, cb) {
        local headers = { "X-Amz-Target": format("%s.DeleteTable", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
    ////////////////////////////////////////////////////////////////////////////
    function DescribeLimits(params, cb) {
        local headers = { "X-Amz-Target": format("%s.DescribeLimits", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
    ////////////////////////////////////////////////////////////////////////////
    function DescribeTable(params, cb) {
        local headers = { "X-Amz-Target": format("%s.DescribeTable", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
    ////////////////////////////////////////////////////////////////////////////
    function GetItem(params, cb) {
        local headers = { "X-Amz-Target": format("%s.GetItem", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
    ////////////////////////////////////////////////////////////////////////////
    function ListTables(params, cb) {
        local headers = { "X-Amz-Target": format("%s.ListTables", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
     ////////////////////////////////////////////////////////////////////////////
    function PutItem(params, cb) {
        local headers = { "X-Amz-Target": format("%s.PutItem", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
     ////////////////////////////////////////////////////////////////////////////
    function Query(params, cb) {
        local headers = { "X-Amz-Target": format("%s.Query", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
     ////////////////////////////////////////////////////////////////////////////
    function Scan(params, cb) {
        local headers = { "X-Amz-Target": format("%s.Scan", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
     ////////////////////////////////////////////////////////////////////////////
    function UpdateItem(params, cb) {
        local headers = { "X-Amz-Target": format("%s.UpdateItem", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

    ////////////////////////////////////////////////////////////////////////////
    // @param {table} params
    // @param {function} cb
     ////////////////////////////////////////////////////////////////////////////
    function UpdateTable(params, cb) {
        local headers = { "X-Amz-Target": format("%s.UpdateTable", TARGET_PREFIX) };
        _awsRequest.post("/", headers, http.jsonencode(params), cb);
    }

}

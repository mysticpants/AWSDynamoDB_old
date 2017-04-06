#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSDynamoDB.class.nut:1.0.0"

const ACCESS_KEY_ID = "YOUR_KEY_ID_HERE";
const SECRET_ACCESS_KEY = "YOUR_KEY_HERE";

db <- AWSDynamoDB("us-west-2", ACCESS_KEY_ID, SECRET_ACCESS_KEY);
deviceId <- imp.configparams.deviceid;
time <- time().tostring();

// PutItem
local putParams = {
	"TableName": "test",
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
    "TableName": "test",
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

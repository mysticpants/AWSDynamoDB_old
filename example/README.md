create tabke
enter name
enter keydefault setting tick


# Demo Instructions

This example shows who to create a DynamoDB database that you will be able to transmit to and receive from.

As the sample code includes the private key verbatim in the source, it should be treated carefully, and not checked into version control!


1. Go to the Database service DynamoDB
1. "Create a table"
	1. Enter a table name "table"
	1. Enter a Partition key "deviceId" ensure the key type is a string
	1. tick the *add sort key* box
	1. Enter a sort key "time" ensure the key type is a string
	1. tick the *used default settings* box
1. Create

The names used align with the *sample.agent.nut* code.

## Setting up Agent Code

Here is some agent [code](sample.agent.nut).

Set the example code configuration parameters Enter your aws keys and your AWS region.

Parameter             | Description
----------------------| -----------
ACCESS_KEY_ID         | IAM Access Key ID
SECRET_ACCESS_KEY     | IAM Secret Access Key

Run the example code and it should send data entries to the database then retrieve these data entries from the database.

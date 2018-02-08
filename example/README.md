# Demo Instructions

This example shows who to create a DynamoDB database that you will be able to transmit to and receive from.

As the sample code includes the private key verbatim in the source, it should be treated carefully, and not checked into version control!


Please ensure your AWS keys have DynamoDB access.

The names used align with the *sample.agent.nut* code.

## Setting up Agent Code

Here is some agent [code](sample.agent.nut).

Set the example code configuration parameters Enter your aws keys and your AWS region.

Parameter                        | Description
-------------------------------- | -----------
AWS_DYNAMO_ACCESS_KEY_ID         | IAM Access Key ID
AWS_DYNAMO_SECRET_ACCESS_KEY     | IAM Secret Access Key
AWS_DYNAMO_REGION                | AWS region

Run the example code and it should create a dynamoDB table, put a item in the table and retrieve it. After this the table is deleted.

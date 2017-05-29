# Demo Instructions

This example shows who to create a DynamoDB database that you will be able to transmit data to and retrieve data from.

As the sample code includes the private key verbatim in the source, it should be treated carefully, and not checked into version control!


## Setting up AIM Policy

1. Select `Services` link (on the top left of the page) and them type `IAM` in the search line
1. Select `IAM Manage User Access and Encryption Keys` item
1. Select `Policies` item from the menu on the left
1. Press `Create Policy` button
1. Press `Select` for `Policy Generator`
1. On the `Edit Permissions` page do the following
    1. Set `Effect` to `Allow`
    1. Set `AWS Service` to `Amazon DynamoDB`
    1. Set `Actions` to `All Actions`
    1. Leave `Amazon Resource Name (ARN)` blank
    1. Press `Add Statement`
    1. Press `Next Step`
1. Give your policy a name, for example, `allow-DynamoDB` and type in into the `Policy Name` field
1. Press `Create Policy`

## Setting up the AIM User

1. Select `Services` link (on the top left of the page) and them type `IAM` in the search line
1. Select the `IAM Manage User Access and Encryption Keys` item
1. Select `Users` item from the menu on the left
1. Press `Add user`
1. Choose a user name, for example `user-calling-DynamoDB`
1. Check `Programmatic access` but not anything else
1. Press `Next: Permissions` button
1. Press `Attach existing policies directly` icon
1. Check `allow-DynamoDB` from the list of policies
1. Press `Next: Review`
1. Press `Create user`
1. Copy down your `Access key ID` and `Secret access key`

The names used align with the *sample.agent.nut* code.

## Setting up Agent Code

Here is some agent [code](sample.agent.nut).

Set the example code configuration parameters Enter your aws keys and your AWS region.

Parameter             			 | Description
-------------------------------- | -----------
AWS_DYNAMO_ACCESS_KEY_ID         | IAM Access Key ID
AWS_DYNAMO_SECRET_ACCESS_KEY     | IAM Secret Access Key
AWS_DYNAMO_REGION				 | AWS region

Run the example code and it should create a dynamoDB table, put a item in the table and retrieve it. After this the table is deleted.

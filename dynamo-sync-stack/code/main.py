import os

import boto3


def get_credentials(role_arn):
    # create an STS client object that represents a live connection to the 
    # STS service
    sts_client = boto3.client('sts')

    # Call the assume_role method of the STSConnection object and pass the role
    # ARN and a role session name.
    assumed_role_object = sts_client.assume_role(
        RoleArn=role_arn,
        RoleSessionName="cross_acct_lambda"
    )

    # From the response that contains the assumed role, get the temporary 
    # credentials that can be used to make subsequent API calls
    return assumed_role_object['Credentials']


# Environment Variables
target_aws_account_num = os.environ['TARGET_AWS_ACCOUNT_NUMBER']
target_role_name = os.environ['TARGET_ROLE_NAME']
target_ddb_name = os.environ['TARGET_DYNAMODB_NAME']

role_arn = "arn:aws:iam::%s:role/%s" % (target_aws_account_num, target_role_name)
sts_response = get_credentials(role_arn)

# Create a DynamoDB client that assumes a role in the target account 
dynamodb = boto3.client(
    'dynamodb',
    aws_access_key_id=sts_response['AccessKeyId'],
    aws_secret_access_key=sts_response['SecretAccessKey'],
    aws_session_token=sts_response['SessionToken']
)


def lambda_handler(event, context):
    Records = event['Records']

    for record in Records:
        event_name = record['eventName']

        if event_name == 'REMOVE':
            dynamodb.delete_item(TableName=target_ddb_name, Key=record['dynamodb']['Keys'])
            print("Removed Keys ", record['dynamodb']['Keys'])
        else:
            dynamodb.put_item(TableName=target_ddb_name, Item=record['dynamodb']['NewImage'])
            print("Put Keys ", record['dynamodb']['Keys'])

import json
import boto3
import os
import logging

scheduler_client = boto3.client('scheduler')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMO_TABLE_NAME'])

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    logger.info(f"Event: {event}")

    pk = event["pk"]
    sk = event["sk"]
        
    expire_appointment(pk, sk)
    delete_schedule(pk, sk)

def expire_appointment(primary_key: str, sort_key: str):
    EXPIRED = True

    table.update_item(
        Key={
            "pk": primary_key,
            "sk": sort_key
        },
        UpdateExpression='SET #isExpired = :val1',
        ExpressionAttributeValues={':val1': EXPIRED },
        ExpressionAttributeNames={
        "#isExpired": "isExpired"
        }
    )
    logger.info(f"Successfully updated the item status to {EXPIRED}")

def delete_schedule(primary_key: str, sort_key: str):
    schedule_name = f"{primary_key}_{sort_key}"
    scheduler_client.delete_schedule(
            GroupName=os.environ['SHEDULE_GROUP'],
            Name=schedule_name
    )
    logger.info(f"Successfully DELETED scheduled event with name {schedule_name}!")
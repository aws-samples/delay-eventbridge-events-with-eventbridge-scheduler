import json
from zoneinfo import ZoneInfo
import boto3
import os
import datetime
import logging

client = boto3.client('scheduler')
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    logger.info(f"Boto3 version: {boto3.__version__}")
    logger.info(f"Event: {event}")
    
    action = event["action"] # "CREATE" or "DELETE"
    primary_key = event["pk"]
    sort_key = event["sk"]

    if action.upper() == "CREATE":
        time_zone = event["time_zone"]
        epoch_flag_date = event["epoch_time_of_flag"]
        expiration_time_in_minutes = event["expiration_time_in_minutes"]
        expire_on_weekend = event["expire_on_weekend"]

        flag_date = datetime.datetime.fromtimestamp(int(epoch_flag_date), tz=ZoneInfo(time_zone))  
        expiration_date = get_expiration_date(flag_date, int(expiration_time_in_minutes), expire_on_weekend)
        try:
            create_schedule(primary_key, sort_key, expiration_date, time_zone)
        except Exception as e:
            if (hasattr(e, "response") and e.response['Error']['Code'] == "ConflictException"):
                logger.error(f"${e.response['Error']['Message']} Schedule already exists. Deleting schedule, and trying to create it again...")
                delete_schedule(primary_key, sort_key)
                create_schedule(primary_key, sort_key, expiration_date, time_zone)
            else: 
                raise e
    elif action.upper() == "DELETE":
        delete_schedule(primary_key, sort_key)
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'Sucessfully done a {action}!')
    }

def get_expiration_date(flag_date: datetime, expiration_time_in_minutes: int, expire_on_weekend: bool):
    # If they allow expirations on weekends, no fancy calculations needed, simply add the time.
    if expire_on_weekend:
        return flag_date + datetime.timedelta(minutes = expiration_time_in_minutes)

    # In the edge case that they set the expiration on a weekend, consider it to be Monday to give the approver more time
    if flag_date.isoweekday() in set((6, 7)): 
        flag_date += datetime.timedelta(days= 8 - flag_date.isoweekday())

    expiration_date = flag_date + datetime.timedelta(minutes = expiration_time_in_minutes)
    if expiration_date.isoweekday() in set((6, 7)):
        expiration_date += datetime.timedelta(days = 8 - expiration_date.isoweekday())
    return expiration_date

def create_schedule(primary_key: str, sort_key: str, expiration_date: datetime, time_zone: str):
    schedule_name = f"{primary_key}_{sort_key}"
    client.create_schedule(
            FlexibleTimeWindow={
                'Mode': 'OFF'
            },
            Name=schedule_name,
            GroupName=os.environ['SHEDULE_GROUP'],
            ScheduleExpression= expiration_date.strftime("at(%Y-%m-%dT%H:%M:%S)"),
            ScheduleExpressionTimezone=time_zone,
            Target={
                'Arn': os.environ['SHEDULE_TARGET_LAMBDA_ARN'],
                'RoleArn': os.environ['SHEDULE_ROLE_ARN'],
                'Input': json.dumps({
                    "pk": primary_key,
                    "sk": sort_key
                }),
                'RetryPolicy': {
                    'MaximumEventAgeInSeconds': 180,
                    'MaximumRetryAttempts': 2
                }
            }
        )
    logger.info(f"Successfully CREATED scheduled event with name {schedule_name}!")
    
def delete_schedule(primary_key: str, sort_key: str):
    schedule_name = f"{primary_key}_{sort_key}"
    client.delete_schedule(
            GroupName=os.environ['SHEDULE_GROUP'],
            Name=schedule_name
    )
    logger.info(f"Successfully DELETED scheduled event with name {schedule_name}!")
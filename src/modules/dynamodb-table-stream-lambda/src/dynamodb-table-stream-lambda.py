import json
import os
import logging
import boto3
from boto3.dynamodb.types import TypeDeserializer

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb_resource = boto3.resource('dynamodb')
dynamodb_table = dynamodb_resource.Table(os.environ.get('DYNAMO_TABLE_NAME'))

# This is the value of 'status' to intitiate delayed event
FLAG = "REQUESTED"
DEFAULT_EXPIRATION_TIME = 2880 # Two days
DEFAULT_EXPIRE_ON_WEEKEND = False # DDon't expire on weekends

def handler(event, context):
    logger.info(f"Event: {event}")

    for record in event["Records"]:
        process_record(record)

    return {
        'statusCode': 200,
        'body': json.dumps('Sucessfully done a something!')
    }

def process_record(record: dict):
    new_image = record.get("dynamodb", {}).get("NewImage", None)
    old_image = record.get("dynamodb", {}).get("OldImage", None)

    new_payload = unmarshal_dynamodb_data(new_image)          
    
    is_new_item = old_image == None
    if is_new_item:
        logger.info(f"New item with status '{FLAG}'")
        if new_payload.get("status") != FLAG:
            logger.info(f"New item does not have the status: {FLAG}, ignoring...")
            return
        
        invoke_create_schedule_handler(
            pk = new_payload.get("pk"), 
            sk = new_payload.get("sk"), 
            epoch_time_of_flag = new_payload.get("epoch_time_of_flag"), 
            time_zone = new_payload.get("time_zone"), 
            expiration_time_in_minutes = new_payload.get("expiration_time_in_minutes", DEFAULT_EXPIRATION_TIME), 
            expire_on_weekend = new_payload.get("expire_on_weekend", DEFAULT_EXPIRE_ON_WEEKEND)
        )
        return

    old_payload = unmarshal_dynamodb_data(old_image)    

    is_status_changed_to_flag = old_payload.get("status") != new_payload.get("status") and new_payload.get("status") == FLAG
    if is_status_changed_to_flag:
        logger.info(f"Status has been changed from a different value, TO '{FLAG}'")
        invoke_create_schedule_handler(
            pk = new_payload.get("pk"), 
            sk = new_payload.get("sk"), 
            epoch_time_of_flag = new_payload.get("epoch_time_of_flag"), 
            time_zone = new_payload.get("time_zone"), 
            expiration_time_in_minutes = new_payload.get("expiration_time_in_minutes", DEFAULT_EXPIRATION_TIME), 
            expire_on_weekend = new_payload.get("expire_on_weekend", DEFAULT_EXPIRE_ON_WEEKEND)
        )
        return

    is_status_changed_out_of_flag = old_payload.get("status") != new_payload.get("status") and old_payload.get("status") == FLAG
    if is_status_changed_out_of_flag:
        logger.info(f"Status has been changed OUT of '{FLAG}'")
        invoke_delete_schedule_handler(
            pk = new_payload.get("pk"), 
            sk = new_payload.get("sk")
        )
        return
    
    logger.info("Status has not been changed, ignoring event...")

def invoke_create_schedule_handler(pk, sk, epoch_time_of_flag, time_zone, expiration_time_in_minutes, expire_on_weekend):
    lambda_client = boto3.client('lambda', region_name=os.environ.get('AWS_REGION'))
    
    payload = {
        'action': "CREATE",
        'pk': pk,
        'sk': sk,
        'epoch_time_of_flag': epoch_time_of_flag,
        'time_zone': time_zone,
        'expiration_time_in_minutes': expiration_time_in_minutes,
        'expire_on_weekend': expire_on_weekend
    }
    
    params = {
        'FunctionName': os.environ.get('EXPIRATION_LAMBDA_NAME'),
        'InvocationType': 'Event',
        'Payload': json.dumps(payload)
    }
    
    logger.info(f'Asynch invoking item expiration lambda with payload {payload}')
    response = lambda_client.invoke(**params)
    logger.info(f'Successfully invoked {os.environ.get("EXPIRATION_LAMBDA_NAME")} with response {response}')

def invoke_delete_schedule_handler(pk, sk):
    lambda_client = boto3.client('lambda', region_name=os.environ.get('AWS_REGION'))
    
    payload = {
        'action': "DELETE",
        'pk': pk,
        'sk': sk,
    }

    params = {
        'FunctionName': os.environ.get('EXPIRATION_LAMBDA_NAME'),
        'InvocationType': 'Event',
        'Payload': json.dumps(payload)
    }
    
    logger.info(f'Asynch invoking item expiration lambda with payload {payload}')
    response = lambda_client.invoke(**params)
    logger.info(f'Successfully invoked {os.environ.get("EXPIRATION_LAMBDA_NAME")} with response {response}')

def unmarshal_dynamodb_data(data):
    deserializer = TypeDeserializer()
    unmarshalled_data = {}

    for key, value in data.items():
        unmarshalled_data[key] = deserializer.deserialize(value)

    return unmarshalled_data
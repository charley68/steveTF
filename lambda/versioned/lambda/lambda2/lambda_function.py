import json

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps("Goodbye, World 2!")
    }

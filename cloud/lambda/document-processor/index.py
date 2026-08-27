import json


def handler(event, context):
    print("document-processor invoked")
    print(f"received SQS event: {event}")

    for record in event.get("Records", []):
        message_body = json.loads(record["body"])

        for s3_record in message_body.get("Records", []):
            event_name = s3_record["eventName"]
            bucket = s3_record["s3"]["bucket"]["name"]
            object_key = s3_record["s3"]["object"]["key"]

            print(f"event: {event_name}")
            print(f"bucket: {bucket}")
            print(f"object: {object_key}")

    return {
        "statusCode": 200,
        "body": "document processed successfully"
    }

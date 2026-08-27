def handler(event, context):
    print("document-processor invoked")
    print(f"event: {event}")

    return {
        "statusCode": 200,
        "body": "document-processor executed successfully"
    }

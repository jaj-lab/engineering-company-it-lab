import json
import os

import psycopg2


def get_db_connection():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        port=os.environ["DB_PORT"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
    )


def handler(event, context):
    print("document-processor invoked")
    print(f"event: {event}")

    records = event.get("Records", [])

    if not records:
        print("No SQS records found")
        return {
            "statusCode": 400,
            "body": "No SQS records found",
        }

    connection = get_db_connection()

    try:
        with connection:
            with connection.cursor() as cursor:

                for record in records:
                    body = json.loads(record["body"])

                    for s3_record in body.get("Records", []):
                        s3 = s3_record["s3"]

                        bucket = s3["bucket"]["name"]
                        object_data = s3["object"]

                        object_key = object_data["key"]
                        event_type = s3_record["eventName"]
                        event_time = s3_record["eventTime"]
                        etag = object_data.get("eTag")
                        size_bytes = object_data.get("size")

                        cursor.execute(
                            """
                            INSERT INTO documents (
                                bucket,
                                object_key,
                                event_type,
                                event_time,
                                etag,
                                size_bytes,
                                status
                            )
                            VALUES (
                                %s,
                                %s,
                                %s,
                                %s,
                                %s,
                                %s,
                                %s
                            )
                            RETURNING id
                            """,
                            (
                                bucket,
                                object_key,
                                event_type,
                                event_time,
                                etag,
                                size_bytes,
                                "received",
                            ),
                        )

                        document_id = cursor.fetchone()[0]

                        print(
                            f"document recorded: "
                            f"id={document_id}, "
                            f"bucket={bucket}, "
                            f"object={object_key}"
                        )

    finally:
        connection.close()

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "document metadata stored",
                "records": len(records),
            }
        ),
    }

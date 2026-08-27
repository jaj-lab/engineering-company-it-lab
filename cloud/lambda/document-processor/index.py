import json
import logging
import os

import boto3
import psycopg2


logger = logging.getLogger()
logger.setLevel(logging.INFO)

secretsmanager = boto3.client("secretsmanager")


def get_database_credentials():
    secret_name = os.environ["SECRET_NAME"]

    response = secretsmanager.get_secret_value(
        SecretId=secret_name
    )

    return json.loads(response["SecretString"])


def get_db_connection(secret):
    return psycopg2.connect(
        host=secret["host"],
        port=secret["port"],
        dbname=secret["dbname"],
        user=secret["username"],
        password=secret["password"],
    )


def handler(event, context):
    logger.info("document-processor invoked")
    logger.info("event: %s", event)

    records = event.get("Records", [])

    if not records:
        logger.warning("No SQS records found")
        return {
            "statusCode": 400,
            "body": "No SQS records found",
        }

    connection = None

    try:
        secret = get_database_credentials()
        connection = get_db_connection(secret)

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

                        logger.info(
                            "document recorded: id=%s, bucket=%s, object=%s",
                            document_id,
                            bucket,
                            object_key,
                        )

    finally:
        if connection is not None:
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

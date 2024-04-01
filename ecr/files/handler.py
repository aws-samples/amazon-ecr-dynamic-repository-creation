import logging
import os
import sys
import boto3
import json

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def run(event, context):
    account_id = event["account"]
    repository = event["detail"]["requestParameters"]["repositoryName"]

    client = boto3.client("ecr")

    try:
        repositories = client.describe_repositories(
            registryId=account_id, repositoryNames=[repository]
        )["repositories"]
    except:
        logger.info("failed to lookup repository %s, probably missing - creating the repository now...", repository)
        repositories = []

    if not repositories:
        try: 

            scan_on_push = bool(os.environ["REPO_SCAN_ON_PUSH"])
            mutability   = os.environ["IMAGE_TAG_MUTABILITY"]

            if os.environ["REPO_TAGS"]:
                 tags = [{"Key": k, "Value": v} for (k, v) in json.loads(os.environ["REPO_TAGS"]).items()]
        except Exception as e:
            logger.error("env variable malformed: %s", e)
        try:
            client.create_repository(
                registryId=account_id,
                repositoryName=repository,
                imageTagMutability=mutability,
                imageScanningConfiguration={"scanOnPush": scan_on_push},
                encryptionConfiguration={"encryptionType": "KMS"},
                tags=tags,
            )
            logger.info("created %s repository", repository)
        except Exception as e:
            logger.error("failed to create repository %s: %s", repository, e)
            sys.exit(1)

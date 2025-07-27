#!/bin/bash

BUCKET_NAME="nagbandi-terraform-state-bucket"
TABLE_NAME="terraform-lock-table"
REGION="ap-south-1"

echo "🔄 Emptying S3 bucket: $BUCKET_NAME..."

aws s3api list-object-versions --bucket $BUCKET_NAME --region $REGION \
  | jq -r '.Versions[]?, .DeleteMarkers[]? | [.Key, .VersionId] | @tsv' \
  | while read -r key version; do
      aws s3api delete-object --bucket "$BUCKET_NAME" --key "$key" --version-id "$version" --region "$REGION"
    done

echo "🗑️ Deleting S3 bucket: $BUCKET_NAME..."
aws s3api delete-bucket --bucket $BUCKET_NAME --region $REGION

echo "🗑️ Deleting DynamoDB table: $TABLE_NAME..."
aws dynamodb delete-table --table-name $TABLE_NAME --region $REGION

echo "✅ Cleanup complete!"

#!/bin/bash

BUCKET_NAME="nagbandi-terraform-state-bucket"
TABLE_NAME="terraform-lock-table"
REGION="ap-south-1"

# Create S3 bucket
aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION \
  --create-bucket-configuration LocationConstraint=$REGION

# Enable versioning (recommended)
aws s3api put-bucket-versioning --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name $TABLE_NAME \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION

echo "✅ S3 bucket and DynamoDB table created."

set -e

# Configuration
BUCKET_PREFIX="terraform-state"

# Detect AWS configuration
get_aws_region() {
    echo -n "Detecting AWS region... "
    REGION=$(aws configure get region)
    if [[ -z "$REGION" ]]; then
        echo "❌ Error: No AWS region configured. Run 'aws configure' to set up your AWS CLI."
        exit 1
    fi
    echo "✔️ Found: $REGION"
}

get_aws_account_and_bucket() {
    echo -n "Getting AWS account ID... "
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    if [[ -z "$ACCOUNT_ID" ]]; then
        echo "❌ Error: Could not get AWS account ID. Make sure you are logged into AWS CLI."
        exit 1
    fi
    echo "✔️ Found: $ACCOUNT_ID"

    BUCKET_NAME="${BUCKET_PREFIX}-${ACCOUNT_ID}"
    echo "✔️ S3 bucket name: $BUCKET_NAME"
}

echo "✅ Starting bootstrap for Terraform environment..."
echo "--------------------------------------------------"

# Detect AWS configuration
get_aws_region
get_aws_account_and_bucket

echo "--------------------------------------------------"
echo "Configuration detected:"
echo "  AWS Region:       $REGION"
echo "  S3 Bucket:        $BUCKET_NAME"
echo "  AWS Account ID:   $ACCOUNT_ID"
echo "--------------------------------------------------"

setup_s3_bucket() {
  echo -n "Checking S3 bucket... "
  if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "✔️ Found."
  else
    echo "❌ Not found. Creating..."
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
    echo "✔️ S3 bucket '$BUCKET_NAME' created."
  fi

  echo ""
  echo "🎯 BUCKET NAME FOR GITHUB SECRETS:"
  echo "   TERRAFORM_STATE_BUCKET=$BUCKET_NAME"
  echo ""
}

# --- 🚀 EXECUTION ---
setup_s3_bucket

echo "--------------------------------------------------"
echo "✅ Backend environment ready."
echo "🚀 Bootstrap completed!"

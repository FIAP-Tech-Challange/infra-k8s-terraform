set -e

# Default values
BUCKET_NAME=""
REGION=""

# Function to display usage
usage() {
    echo "Usage: $0 --bucket=<bucket-name> --region=<aws-region>"
    echo ""
    echo "Required parameters:"
    echo "  --bucket      S3 bucket name for Terraform state"
    echo "  --region      AWS region"
    echo ""
    echo "Example:"
    echo "  $0 --bucket=my-terraform-state --region=us-east-1"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --bucket=*)
            BUCKET_NAME="${1#*=}"
            shift
            ;;
        --region=*)
            REGION="${1#*=}"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "❌ Error: Unknown parameter $1"
            usage
            ;;
    esac
done

# Validate required parameters
if [[ -z "$BUCKET_NAME" ]]; then
    echo "❌ Error: --bucket is required"
    usage
fi

if [[ -z "$REGION" ]]; then
    echo "❌ Error: --region is required"
    usage
fi

echo "✅ Starting bootstrap for Terraform environment..."
echo "--------------------------------------------------"

echo "S3 Bucket:        $BUCKET_NAME"
echo "AWS Region:       $REGION"
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
}

# --- 🚀 EXECUTION ---
setup_s3_bucket

echo "--------------------------------------------------"
echo "✅ Backend environment ready."
echo "🚀 Bootstrap completed!"
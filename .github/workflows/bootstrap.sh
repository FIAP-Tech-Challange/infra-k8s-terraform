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
            echo "❌ Erro: Parâmetro desconhecido $1"
            usage
            ;;
    esac
done

# Validate required parameters
if [[ -z "$BUCKET_NAME" ]]; then
    echo "❌ Erro: --bucket é obrigatório"
    usage
fi

if [[ -z "$REGION" ]]; then
    echo "❌ Erro: --region é obrigatório"
    usage
fi

echo "✅ Iniciando bootstrap para o ambiente Terraform..."
echo "--------------------------------------------------"

echo "Bucket S3:        $BUCKET_NAME"
echo "Região AWS:       $REGION"
echo "--------------------------------------------------"

setup_s3_bucket() {
  echo -n "Verificando bucket S3... "
  if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "✔️ Encontrado."
  else
    echo "❌ Não encontrado. Criando..."
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
    echo "✔️ Bucket S3 '$BUCKET_NAME' criado."
  fi
}

# --- 🚀 EXECUÇÃO ---
setup_s3_bucket

echo "--------------------------------------------------"
echo "✅ Ambiente de backend pronto."
echo "🚀 Bootstrap concluído!"
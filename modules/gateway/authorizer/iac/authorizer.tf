# Use existing LabRole for Lambda Cluster (AWS Academy compatible)
data "aws_iam_role" "authorizer_lambda_role" {
  name = "LabRole"
}

# Note: LabRole in AWS Academy already has necessary permissions
# Skipping policy attachment as it's not allowed in AWS Academy environment

# CloudWatch log group for the Lambda function
resource "aws_cloudwatch_log_group" "authorizer_lambda_logs" {
  name              = "/aws/lambda/${var.authorizer_function_name}"
  retention_in_days = 1
}

# Run npm install before zipping
resource "null_resource" "npm_install" {
  triggers = {
    package_json = filemd5("${path.module}/../package.json")
    package_lock = filemd5("${path.module}/../package-lock.json")
  }

  provisioner "local-exec" {
    command     = "npm install --production"
    working_dir = "${path.module}/.."
  }
}

# Archive the Lambda function code
data "archive_file" "authorizer_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/.."
  output_path = "${path.module}/../authorizer-lambda.zip"
  excludes    = [
    "iac/**",
    "*.zip",
    ".git/**"
  ]

  depends_on = [null_resource.npm_install]
}

# Lambda function for the authorizer
resource "aws_lambda_function" "authorizer" {
  filename         = data.archive_file.authorizer_lambda_zip.output_path
  function_name    = var.authorizer_function_name
  role            = data.aws_iam_role.authorizer_lambda_role.arn
  handler         = "src/index.handler"
  runtime         = "nodejs18.x"
  timeout         = 10

  source_code_hash = data.archive_file.authorizer_lambda_zip.output_base64sha256

  depends_on = [
    aws_cloudwatch_log_group.authorizer_lambda_logs,
  ]

  environment {
    variables = {
      LOG_LEVEL = "INFO"
      DB_PORT   = var.database_port
      DB_USER   = var.database_user
      DB_HOST   = var.database_host
      DB_NAME   = var.database_name
      DB_PASSWORD   = var.database_password
    }
  }
}

# Outputs
output "authorizer_function_name" {
  description = "Name of the authorizer Lambda function"
  value       = aws_lambda_function.authorizer.function_name
}

output "authorizer_function_arn" {
  description = "ARN of the authorizer Lambda function"
  value       = aws_lambda_function.authorizer.arn
}

output "authorizer_invoke_arn" {
  description = "Invoke ARN of the authorizer Lambda function"
  value       = aws_lambda_function.authorizer.invoke_arn
}

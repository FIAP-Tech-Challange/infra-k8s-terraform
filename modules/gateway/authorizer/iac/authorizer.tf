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



# Create zip file manually to ensure node_modules is included
resource "null_resource" "create_lambda_zip" {
  triggers = {
    src_files = sha256(join("", [for f in fileset("${path.module}/../src", "**") : filesha256("${path.module}/../src/${f}")]))
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "rm -f authorizer-lambda.zip && zip -r authorizer-lambda.zip src/ node_modules/ package.json package-lock.json -x 'iac/*' '__tests__/*' '*.zip' '*.md' 'jest.config.js' 'jest.setup.js' '.babelrc' '.git/*'"
    working_dir = "${path.module}/.."
  }
}



# Lambda function for the authorizer
resource "aws_lambda_function" "authorizer" {
  filename         = "${path.module}/../authorizer-lambda.zip"
  function_name    = var.authorizer_function_name
  role            = data.aws_iam_role.authorizer_lambda_role.arn
  handler         = "src/index.handler"
  runtime         = "nodejs18.x"
  timeout         = 30

  source_code_hash = base64encode(sha256(join("", [
    filemd5("${path.module}/../package.json"),
    filemd5("${path.module}/../package-lock.json"),
    tostring(null_resource.create_lambda_zip.triggers.src_files)
  ])))

  depends_on = [
    aws_cloudwatch_log_group.authorizer_lambda_logs,
    null_resource.create_lambda_zip,
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

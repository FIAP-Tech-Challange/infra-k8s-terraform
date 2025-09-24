# IAM role for the Lambda authorizer
resource "aws_iam_role" "authorizer_lambda_role" {
  name = "lambda-role-${var.authorizer_function_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy attachment for basic Lambda execution
resource "aws_iam_role_policy_attachment" "authorizer_lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.authorizer_lambda_role.name
}

# CloudWatch log group for the Lambda function
resource "aws_cloudwatch_log_group" "authorizer_lambda_logs" {
  name              = "/aws/lambda/${var.authorizer_function_name}"
  retention_in_days = 1
}

# Archive the Lambda function code
data "archive_file" "authorizer_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/.."
  output_path = "${path.module}/authorizer-lambda.zip"
  excludes    = ["*.zip", "iac/"]
}

# Lambda function for the authorizer
resource "aws_lambda_function" "authorizer" {
  filename         = data.archive_file.authorizer_lambda_zip.output_path
  function_name    = var.authorizer_function_name
  role            = aws_iam_role.authorizer_lambda_role.arn
  handler         = "src/index.handler"
  runtime         = "nodejs18.x"
  timeout         = 10

  source_code_hash = data.archive_file.authorizer_lambda_zip.output_base64sha256

  depends_on = [
    aws_iam_role_policy_attachment.authorizer_lambda_basic,
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

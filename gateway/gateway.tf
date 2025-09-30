data "aws_lambda_function" "cpf_validation_function" {
  function_name = var.lambda_function_name
}

# Include the authorizer module
module "authorizer" {
  source = "./authorizer/iac"

  authorizer_function_name = var.authorizer_function_name
  database_port            = var.database_port
  database_user            = var.database_user
  database_host            = var.database_host
  database_name            = var.database_name
  database_password        = var.database_password
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "api-gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = data.aws_lambda_function.cpf_validation_function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_authorizer" "lambda_authorizer" {
  api_id                            = aws_apigatewayv2_api.http_api.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = module.authorizer.authorizer_invoke_arn
  identity_sources                  = ["$request.header.Authorization"]
  name                              = "lambda-authorizer"
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
}

resource "aws_apigatewayv2_route" "cpf-validation-route" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "POST /cpf-validation"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_authorizer.id
  authorization_type = "CUSTOM"
}

resource "aws_lambda_permission" "api_gw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.cpf_validation_function.function_name
  principal     = "apigateway.amazonaws.com"

  # The source ARN is the ARN of the API Gateway
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gw_invoke_authorizer" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.authorizer.authorizer_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.lambda_authorizer.id}"
}

resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id     = aws_apigatewayv2_api.http_api.id
  depends_on = [aws_apigatewayv2_route.cpf-validation-route]
}

resource "aws_apigatewayv2_stage" "prod_stage" {
  api_id        = aws_apigatewayv2_api.http_api.id
  name          = "prod"
  deployment_id = aws_apigatewayv2_deployment.api_deployment.id
}

output "api_validate_cpf" {
  value = "${aws_apigatewayv2_stage.prod_stage.invoke_url}/cpf-validation"
}

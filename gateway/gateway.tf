data "aws_lambda_function" "get_function" {
  function_name = var.lambda_function_name
}

# Include the authorizer module
module "authorizer" {
  source = "./authorizer"

  authorizer_function_name = var.authorizer_function_name
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "sahdo-lambda-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = data.aws_lambda_function.get_function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_authorizer" "lambda_authorizer" {
  api_id                            = aws_apigatewayv2_api.http_api.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = module.authorizer.authorizer_invoke_arn
  identity_sources                  = ["$request.header.Authorization"]
  name                              = "sahdo-lambda-authorizer"
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
}

resource "aws_apigatewayv2_route" "hello_route_authorized" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "GET /hello-auth"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_authorizer.id
  authorization_type = "CUSTOM"
}

resource "aws_lambda_permission" "api_gw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.get_function.function_name
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
  depends_on = [aws_apigatewayv2_route.hello_route_authorized]
}

resource "aws_apigatewayv2_stage" "prod_stage" {
  api_id        = aws_apigatewayv2_api.http_api.id
  name          = "prod"
  deployment_id = aws_apigatewayv2_deployment.api_deployment.id
}

output "api_hello_auth" {
  value = "${aws_apigatewayv2_stage.prod_stage.invoke_url}/hello-auth"
}

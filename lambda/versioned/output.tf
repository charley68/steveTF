
output "invoke_url" {
  description = "Base URL for API Gateway stage."
  value = aws_api_gateway_stage.preprod_stage.invoke_url
}



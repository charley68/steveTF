
output "invoke_url" {
  description = "Base URL for API Gateway stage."
  value = module.apigateway.stage_invoke_urls
}

output "functions" {
  value = module.lambdas.lambda_function_names
}
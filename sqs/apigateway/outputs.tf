output "transAPIKey" {
  value = aws_api_gateway_api_key.trans-apikey.value
  sensitive = true
}

output "transRESTURL" {
    value = aws_api_gateway_stage.development.invoke_url
}
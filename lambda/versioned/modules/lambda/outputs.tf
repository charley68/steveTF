output "lambda_function_names" {
  value = [for lambda in aws_lambda_function.lambda_function : lambda.function_name]
}

output "lambda_alias_name" {
  value = [for alias in aws_lambda_alias.lambda_alias: alias.name]
}

output "lambda_arn" {
  value = { for lambda in aws_lambda_function.lambda_function : lambda.function_name => lambda.arn }
}

resource "aws_lambda_function" "lambda_function" {
  

  for_each = { for idx, function in var.functions : idx => function }

 
  filename         = data.archive_file.lambda_zip[each.key].output_path
  function_name    = each.value.function_name
  role             = var.role_arn
  handler          = var.handler
  runtime          = var.runtime
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip[each.key].output_path)
  publish          = true


  environment {
    variables = var.environment_vars
  }

  tags = var.tags
}

resource "aws_lambda_alias" "lambda_alias" {

  for_each = { for idx, function in var.functions : idx => function }
  name             = var.alias_name
  function_name    = aws_lambda_function.lambda_function[each.key].function_name
  function_version = aws_lambda_function.lambda_function[each.key].version
}

resource "aws_lambda_permission" "lambda_permission" {

  for_each = { for idx, function in var.functions : idx => function }
  depends_on       = [aws_lambda_alias.lambda_alias]
  statement_id     = var.permission_statement_id
  action           = "lambda:InvokeFunction"
  function_name    = "${aws_lambda_function.lambda_function[each.key].function_name}:${var.alias_name}"
  principal        = var.principal
  source_arn       = each.value.gateway_arn
}

data "archive_file" "lambda_zip" {
  for_each = { for idx, function in var.functions : idx => function }

  type        = "zip"
  source_dir  = each.value.function_src
  output_path = "${each.value.function_src}/lambda.zip"
}
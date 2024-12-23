resource "aws_lambda_function" "lambda_function" {
  
  filename                       = data.archive_file.lambda_zip.output_path
  function_name    = var.function_name
  role             = var.role_arn
  handler          = var.handler
  runtime          = var.runtime
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  publish          = true

  environment {
    variables = var.environment_vars
  }

  tags = var.tags
}

resource "aws_lambda_alias" "lambda_alias" {
  name             = var.alias_name
  function_name    = aws_lambda_function.lambda_function.function_name
  function_version = aws_lambda_function.lambda_function.version
}

resource "aws_lambda_permission" "lambda_permission" {
  depends_on       = [aws_lambda_alias.lambda_alias]
  statement_id     = var.permission_statement_id
  action           = "lambda:InvokeFunction"
  function_name    = "${aws_lambda_function.lambda_function.function_name}:${var.alias_name}"
  principal        = var.principal
  source_arn       = var.apigateway_arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${var.source_dir}/lambda.zip"
}

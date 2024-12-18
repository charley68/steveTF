
resource "aws_lambda_function" "hello_world" {
  filename         = "lambda/lambda1/lambda.zip" # Replace with your actual zip file
  function_name    = "hello-world"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler" # Python handler: file.function
  runtime          = "python3.9" # Change to your desired Python version
  source_code_hash = filebase64sha256(data.archive_file.hello_world_function.output_path)
  publish          = true # This ensures a new version is published
}


resource "aws_lambda_alias" "hello_world_STAGE" {
  name             = "staging" # Alias name
  function_name    = aws_lambda_function.hello_world.function_name
  function_version = aws_lambda_function.hello_world.version
}


# This one creates a prod alias only if one doesnt exist and ignores
# udpates of the function_version so only staging repoints to latest version.
# The prod alias would be updated by another process or manually once staging has
# been tested.

resource "aws_lambda_alias" "hello_world_PROD" {

  name             = "prod" # Alias name
  function_name    = aws_lambda_function.hello_world.function_name
  function_version = aws_lambda_function.hello_world.version

  lifecycle {

    ignore_changes = [function_version]
  }
}

# We have to give permission to the lambda alias's
resource "aws_lambda_permission" "preProd_invoke" {

  depends_on = [ aws_lambda_alias.hello_world_STAGE ]
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "hello-world:staging"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.hello_world_api.execution_arn}/*/GET/${aws_lambda_function.hello_world.function_name}"
}

resource "aws_lambda_permission" "prod_invoke" {
  depends_on = [ aws_lambda_alias.hello_world_PROD ]
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "hello-world:prod"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.hello_world_api.execution_arn}/*/GET/${aws_lambda_function.hello_world.function_name}"
}


data "archive_file" "hello_world_function" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/lambda1"
  output_path = "${path.module}/lambda/lambda1/lambda.zip"
}
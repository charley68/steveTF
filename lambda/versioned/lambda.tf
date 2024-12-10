locals {
  aliases = ["staging", "prod"] # Add more aliases as needed
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_hello_world_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "preProd_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:eu-west-2:717279690473:function:hello-world:staging"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.hello_world_api.execution_arn}/*/GET/${aws_lambda_function.hello_world.function_name}"
}

resource "aws_lambda_permission" "prod_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:eu-west-2:717279690473:function:hello-world:prod"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.hello_world_api.execution_arn}/*/GET/${aws_lambda_function.hello_world.function_name}"
}



resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello_world" {
  filename         = "lambda/lambda.zip" # Replace with your actual zip file
  function_name    = "hello-world"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler" # Python handler: file.function
  runtime          = "python3.9" # Change to your desired Python version
  source_code_hash = filebase64sha256(data.archive_file.hello_world_function.output_path)
  publish          = true # This ensures a new version is published
}


resource "aws_lambda_alias" "hello_world_DEV" {
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

data "archive_file" "hello_world_function" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda/lambda.zip"
}

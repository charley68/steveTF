module "hello_world_lambda" {
  source               = "./modules/lambda"

  function_name        = "hello-world"
  source_dir           = "${path.module}/lambda/lambda1"
  alias_name           = "staging"
  apigateway_arn       = "${aws_api_gateway_rest_api.steve_api.execution_arn}/*/GET/hello-world"
  role_arn             = aws_iam_role.lambda_role.arn
  tags                 = { Name = "Steve-lambda" }
}

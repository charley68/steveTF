module "hello_world_lambda" {
  source               = "./modules/lambda"

  function_name        = "hello-world"
  source_dir           = "${path.module}/lambda/lambda1"
  alias_name           = "preProd"
  apigateway_arn       = "${module.apigateway.execution_arn}/*/GET/hello-world"

  role_arn             = aws_iam_role.lambda_role.arn
  tags                 = { Name = "Steve-lambda" }
}

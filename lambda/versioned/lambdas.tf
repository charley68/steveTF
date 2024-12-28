module "lambdas" {
  source               = "./modules/lambda"

  functions = [
        {function_name = "goodbye-world", function_src = "${path.module}/lambda/lambda2", gateway_arn = "${module.apigateway.execution_arn}/*/GET/goodbye-world"},
        {function_name = "hello-world", function_src = "${path.module}/lambda/lambda1", gateway_arn = "${module.apigateway.execution_arn}/*/GET/hello-world"}
  ]
 
  alias_name           = "preProd"
  role_arn             = aws_iam_role.lambda_role.arn
  tags                 = { Name = "Steve-lambda" }
}

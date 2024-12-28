


This terraform setup will build a labda function and setup alias.  Run it twice with a modification to the hello-world.lambda the second time.
The idea here is that we have two version of Lamnda  (1 & 2).  We create two Alias  (staging and prod).  Staging will point to the latest version 
of the lambda whilst prod will typically point to the previous (or last deployed) version.

We then create two stages  (pre-prod and prod).   Both stages define an environment variable called  "lambdaAlias".  The pre-prod stage sets this variable
to staging and the prod stage sets this variable to "prod"

The APIGateway references this variable dynamically as $${stageVariables.lambdaAlias} which gets resolved at runtime

(note the $$ seems necessary for TF,  in AWS directly, we only need $)

Now you can run the following for stage "pre-prod" and stage "prod" and each should point to a different version of the lamnda.


MODULES

I recreted this using modules.  One for APIGateway and one for Lambda.  A single module now creates all the Lambdas.  Not sure if tis is good design or not -possibly not.

ie now you can do:

module "lambdas" {
  source               = "./modules/lambda"

  functions = [
        {function_name = "goodbye-world", function_src = "${path.module}/lambda/lambda2", gateway_arn = "${module.apigateway.execution_arn}/*/GET/goodbye-world"},
        {function_name = "hello-world", function_src = "${path.module}/lambda/lambda1", gateway_arn = "${module.apigateway.execution_arn}/*/GET/hello-world"}
  ]


but maybe better was what i had before which was:


module "hello_world_lambda" {
  source               = "./modules/lambda"

  function_name        = "hello-world"
  source_dir           = "${path.module}/lambda/lambda1"
  alias_name           = "preProd"
  apigateway_arn       = "${module.apigateway.execution_arn}/*/GET/hello-world"

  role_arn             = aws_iam_role.lambda_role.arn
  tags                 = { Name = "Steve-lambda" }
}

module "goodbye_world_lambda" {
  source               = "./modules/lambda"

  function_name        = "goodbye-world"
  source_dir           = "${path.module}/lambda/lambda2"
  alias_name           = "preProd"
  apigateway_arn       = "${module.apigateway.execution_arn}/*/GET/goodbye-world"

  role_arn             = aws_iam_role.lambda_role.arn
  tags                 = { Name = "Steve-lambda" }
}






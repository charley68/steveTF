# API Gateway REST API
resource "aws_api_gateway_rest_api" "hello_world_api" {
  name        = "hello-world-api"
  description = "API Gateway for hello-world Lambda function"
}

# API Gateway Resource (Root Path)
resource "aws_api_gateway_resource" "hello_world_resource" {
  rest_api_id = aws_api_gateway_rest_api.hello_world_api.id
  parent_id   = aws_api_gateway_rest_api.hello_world_api.root_resource_id
  path_part   = "hello-world"
}

# API Gateway Method (HTTP GET)
resource "aws_api_gateway_method" "hello_world_method" {
  rest_api_id   = aws_api_gateway_rest_api.hello_world_api.id
  resource_id   = aws_api_gateway_resource.hello_world_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Integration with Lambda (Uses Stage Variables)
resource "aws_api_gateway_integration" "hello_world_integration" {
  rest_api_id             = aws_api_gateway_rest_api.hello_world_api.id
  resource_id             = aws_api_gateway_resource.hello_world_resource.id
  http_method             = aws_api_gateway_method.hello_world_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  # URI dynamically references stageVariables
  # ${stageVariables.myStage}
  uri = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/${aws_lambda_function.hello_world.arn}:$${stageVariables.lambdaAlias}/invocations"
}

resource "aws_cloudwatch_log_group" "api_gateway_logs" {
 name              = "/aws/apigateway/hello-world"
 retention_in_days = 7
}


resource "aws_api_gateway_stage" "preprod_stage" {
  stage_name    = "pre-prod"
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.hello_world_api.id

  # Define stage variables for pre-prod
  variables = {
    lambdaAlias = "staging" # Points to Lambda alias "staging"
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format          = "{\"requestId\":\"$context.requestId\",\"ip\":\"$context.identity.sourceIp\",\"caller\":\"$context.identity.caller\",\"user\":\"$context.identity.user\",\"requestTime\":\"$context.requestTime\",\"httpMethod\":\"$context.httpMethod\",\"resourcePath\":\"$context.resourcePath\",\"status\":\"$context.status\",\"protocol\":\"$context.protocol\",\"responseLength\":\"$context.responseLength\"}"
  }
}

resource "aws_api_gateway_stage" "prod_stage" {
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.hello_world_api.id

  # Define stage variables for pre-prod
  variables = {
    lambdaAlias = "prod" # Points to Lambda alias "staging"
  }
}


# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.hello_world_api.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.hello_world_integration
  ]
}

resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch" {
  name               = "api_gateway_cloudwatch_global"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "cloudwatch" {
  name   = "default"
  role   = aws_iam_role.cloudwatch.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}


resource "aws_api_gateway_domain_name" "custom_domain" {
  domain_name = "api.surepol.com"
  //certificate_arn = local.SSLCertificate
  regional_certificate_arn = "arn:aws:acm:eu-west-2:717279690473:certificate/8aac3c0d-fdb2-4d0d-ab7c-e46a1a5e34db"

  # NOTE IF/WHEN WE SET THiS TO EDGE
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


resource "aws_api_gateway_base_path_mapping" "staging_mapping" {
  depends_on = [ aws_api_gateway_stage.preprod_stage ]
  api_id = aws_api_gateway_rest_api.hello_world_api.id 
  stage_name  = "pre-prod"
  base_path   = "pre-prod"
  domain_name = aws_api_gateway_domain_name.custom_domain.domain_name
}

resource "aws_api_gateway_base_path_mapping" "prod_mapping" {
  depends_on = [ aws_api_gateway_stage.prod_stage ]
  api_id = aws_api_gateway_rest_api.hello_world_api.id 
  stage_name  = "prod"
  domain_name = aws_api_gateway_domain_name.custom_domain.domain_name
}

resource "aws_route53_record" "custom_domain_alias" {
  zone_id = "Z00347011S1MYBDO0EHRL"
  name    = aws_api_gateway_domain_name.custom_domain.domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.custom_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain.regional_zone_id
    evaluate_target_health = false
  }
}

resource "aws_api_gateway_rest_api" "trans-api" {

  name = var.transGateway

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

/*
resource "aws_api_gateway_resource" "trans" {
  rest_api_id = aws_api_gateway_rest_api.trans-api.id
  parent_id   = aws_api_gateway_rest_api.trans-api.root_resource_id
  path_part   = "sqs"
}*/

resource "aws_api_gateway_method" "trans-post" {
  rest_api_id   = aws_api_gateway_rest_api.trans-api.id
  resource_id   = aws_api_gateway_rest_api.trans-api.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}


resource "aws_api_gateway_integration" "transIntRequest" {
  rest_api_id = aws_api_gateway_rest_api.trans-api.id
  resource_id = aws_api_gateway_rest_api.trans-api.root_resource_id
  type        = "AWS"
  http_method = "POST"
  integration_http_method = "POST"
  uri         = "arn:aws:apigateway:${var.region}:sqs:path/${data.aws_caller_identity.current.account_id}/${var.SQSQueue}"

  credentials  = aws_iam_role.APIRole.arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = <<EOF
Action=SendMessage&MessageBody=$input.body
EOF
  }

  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration_response" "transIntResponse" {
  depends_on = [ aws_api_gateway_integration.transIntRequest ]
  rest_api_id = aws_api_gateway_rest_api.trans-api.id
  resource_id = aws_api_gateway_rest_api.trans-api.root_resource_id
  
  http_method  = aws_api_gateway_method.trans-post.http_method
  status_code = 200

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "transMethodResponse" {
  rest_api_id = aws_api_gateway_rest_api.trans-api.id
  resource_id = aws_api_gateway_rest_api.trans-api.root_resource_id
  http_method  = aws_api_gateway_method.trans-post.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_api_key" "trans-apikey" {
  name = var.transAPIKey
}


resource "aws_api_gateway_deployment" "transDeploy" {
  depends_on = [aws_api_gateway_integration.transIntRequest]

  rest_api_id = aws_api_gateway_rest_api.trans-api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.trans-api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "development" {
  deployment_id = aws_api_gateway_deployment.transDeploy.id
  rest_api_id   = aws_api_gateway_rest_api.trans-api.id
  stage_name    = "development"
}



resource "aws_api_gateway_usage_plan" "transUsage" {
  name         = "my-usage-plan"
  description  = "my description"
  product_code = "MYCODE"

  api_stages {
    api_id = aws_api_gateway_rest_api.trans-api.id
    stage  = aws_api_gateway_stage.development.stage_name
  }
}

# Associate the API key with the usage plan
resource "aws_api_gateway_usage_plan_key" "example_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.trans-apikey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.transUsage.id
}
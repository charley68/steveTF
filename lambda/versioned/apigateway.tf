# Create the intial API Gateway Itself
resource "aws_api_gateway_rest_api" "steve_api" {
  name        = "steve-api"
  description = "API Gateway for hello-world Lambda function"
}

# Create the GATEWAY STAGES  (if we want to be able to deploy to different stages)
resource "aws_api_gateway_stage" "preprod_stage" {
  stage_name    = "pre-prod"
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.steve_api.id

  # Define stage variables for pre-prod
  variables = {
    lambdaAlias = "staging" # Points to Lambda alias "staging"
  }
}


resource "aws_api_gateway_stage" "prod_stage" {
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.steve_api.id

  # Define stage variables for pre-prod
  variables = {
    lambdaAlias = "prod" # Points to Lambda alias "staging"
  }
}



# in the path itself such as  api.surepol.com/prod/myMethod ..... or you can direct api.surepol.com => prod
# We want to say if the path is api.mydomain.com/pre-prod/hello,  direct it to the pre-prod stage
resource "aws_api_gateway_base_path_mapping" "staging_mapping" {
  depends_on = [ aws_api_gateway_stage.preprod_stage ]
  api_id = aws_api_gateway_rest_api.steve_api.id 
  stage_name  = "pre-prod"
  base_path   = "pre-prod"
  domain_name = aws_api_gateway_domain_name.custom_domain.domain_name
}


# we want to say if the path is api.mydomain.com/hello,  direct it to the prod stage
resource "aws_api_gateway_base_path_mapping" "prod_mapping" {
  depends_on = [ aws_api_gateway_stage.prod_stage ]
  api_id = aws_api_gateway_rest_api.steve_api.id 
  stage_name  = "prod"
  domain_name = aws_api_gateway_domain_name.custom_domain.domain_name
}




###### CREATE THE RESROUCES / METHODDS ###########

######################################## HELLO WORLD ########################################

# API Gateway Resource (Root Path)
resource "aws_api_gateway_resource" "hello_world_resource" {
  rest_api_id = aws_api_gateway_rest_api.steve_api.id
  parent_id   = aws_api_gateway_rest_api.steve_api.root_resource_id
  path_part   = "hello-world"
}

# API Gateway Method (HTTP GET)
resource "aws_api_gateway_method" "hello_world_method" {
  rest_api_id   = aws_api_gateway_rest_api.steve_api.id
  resource_id   = aws_api_gateway_resource.hello_world_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Integration with Lambda (Uses Stage Variables)
resource "aws_api_gateway_integration" "hello_world_integration" {
  rest_api_id             = aws_api_gateway_rest_api.steve_api.id
  resource_id             = aws_api_gateway_resource.hello_world_resource.id
  http_method             = aws_api_gateway_method.hello_world_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  # URI dynamically references stageVariables
  # ${stageVariables.myStage}
  uri = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/${module.hello_world_lambda.lambda_arn}:$${stageVariables.lambdaAlias}/invocations"
}


######################################## GOODBYE WORLD ########################################
# API Gateway Resource (Root Path)

resource "aws_api_gateway_resource" "goodbye_world_resource" {
  rest_api_id = aws_api_gateway_rest_api.steve_api.id
  parent_id   = aws_api_gateway_rest_api.steve_api.root_resource_id
  path_part   = "goodbye-world"
}

# API Gateway Method (HTTP GET)
resource "aws_api_gateway_method" "goodbye_world_method" {
  rest_api_id   = aws_api_gateway_rest_api.steve_api.id
  resource_id   = aws_api_gateway_resource.goodbye_world_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Integration with Lambda (Uses Stage Variables)
resource "aws_api_gateway_integration" "goodbye_world_integration" {
  rest_api_id             = aws_api_gateway_rest_api.steve_api.id
  resource_id             = aws_api_gateway_resource.goodbye_world_resource.id
  http_method             = aws_api_gateway_method.goodbye_world_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  # URI dynamically references stageVariables
  # ${stageVariables.myStage}
  uri = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/${module.goodbye_world_lambda.lambda_arn}:$${stageVariables.lambdaAlias}/invocations"
}








# Deploy the API
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.steve_api.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.hello_world_integration,
    aws_api_gateway_integration.goodbye_world_integration
  ]
}











# These two resources (aws_api_gateway_domain_name) and (aws_route53_record) are required together.
# aws_api_gateway_domain_name:  ->    Configures API Gateway to accept traffic for the custom domain.
# aws_route53_record:  ->             Configures Route 53 to route traffic from your custom domain to the API Gateway's Regional endpoint.
resource "aws_api_gateway_domain_name" "custom_domain" {
  domain_name = "api.surepol.com"
  //certificate_arn = local.SSLCertificate
  regional_certificate_arn = "arn:aws:acm:eu-west-2:717279690473:certificate/8aac3c0d-fdb2-4d0d-ab7c-e46a1a5e34db"

  # NOTE IF/WHEN WE SET THiS TO EDGE
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


#  See "aws_api_gateway_domain_name"  above
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

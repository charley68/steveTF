resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = "Steve API Gateway"
}

resource "aws_api_gateway_stage" "stage" {

  for_each = var.stages
  stage_name    = each.key
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id

  # Define stage variables
  variables = {
    lambdaAlias = each.key 
  }
}


resource "aws_api_gateway_base_path_mapping" "staging_mapping" {
  for_each = var.stages
  depends_on = [ aws_api_gateway_stage.stage ]
  api_id = aws_api_gateway_rest_api.api.id 
  stage_name  = each.key
  base_path   = each.value
  domain_name = aws_api_gateway_domain_name.custom_domain.domain_name
}


# Deploy the API
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.integration
  ]
}



# These two resources (aws_api_gateway_domain_name) and (aws_route53_record) are required together.
# aws_api_gateway_domain_name:  ->    Configures API Gateway to accept traffic for the custom domain.
# aws_route53_record:  ->             Configures Route 53 to route traffic from your custom domain to the API Gateway's Regional endpoint.
resource "aws_api_gateway_domain_name" "custom_domain" {
  domain_name = var.domain_name
  regional_certificate_arn = var.regional_certificate_arn

  # NOTE IF/WHEN WE SET THiS TO EDGE
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


#  See "aws_api_gateway_domain_name"  above
resource "aws_route53_record" "custom_domain_alias" {
  zone_id = var.zone_id
  name    = aws_api_gateway_domain_name.custom_domain.domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.custom_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain.regional_zone_id
    evaluate_target_health = false
  }
}

############################################

# API Gateway Resource (Root Path)
resource "aws_api_gateway_resource" "resource" {

  for_each = { for idx, route in var.api_routes : idx => route }

  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.value.path_part
}

# API Gateway Method (HTTP GET)
resource "aws_api_gateway_method" "method" {
  
  for_each = { for idx, route in var.api_routes : idx => route }

  rest_api_id   = aws_api_gateway_rest_api. api.id
  resource_id   = aws_api_gateway_resource.resource[each.key].id
  http_method   = each.value.http_method
  authorization = "NONE"
}

# API Gateway Integration with Lambda (Uses Stage Variables)
resource "aws_api_gateway_integration" "integration" {
  
  for_each = { for idx, route in var.api_routes : idx => route }

  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource[each.key].id
  http_method             = each.value.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  # URI dynamically references stageVariables
  # ${stageVariables.myStage}
  uri = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/${each.value.lambda_arn}:$${stageVariables.lambdaAlias}/invocations"
}
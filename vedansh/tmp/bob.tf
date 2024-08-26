# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "wgplha8hib/xy55oh/GET"
resource "aws_api_gateway_integration" "short_integration" {
  cache_key_parameters    = []
  cache_namespace         = "xy55oh"
  connection_id           = null
  connection_type         = "INTERNET"
  content_handling        = "CONVERT_TO_TEXT"
  credentials             = null
  http_method             = "GET"
  integration_http_method = "POST"
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_parameters      = {}
  request_templates = {
    "application/json" = "{\n    \"short_id\": \"$input.params('shortid')\"\n}"
  }
  resource_id          = "xy55oh"
  rest_api_id          = "wgplha8hib"
  timeout_milliseconds = 29000
  type                 = "AWS"
  uri                  = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-2:868171460502:function:url-shortener-retrieve/invocations"
}

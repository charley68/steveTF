output "execution_arn" {
  value = aws_api_gateway_rest_api.api.execution_arn
}

output "stage_invoke_urls" {

  value = {
    #for stage_name, stage in aws_api_gateway_stage.stage : stage_name => stage.invoke_url
    for stage_name, mapping in aws_api_gateway_base_path_mapping.staging_mapping :
        stage_name => "https://${aws_api_gateway_domain_name.custom_domain.domain_name}/${mapping.base_path}"
    }
}
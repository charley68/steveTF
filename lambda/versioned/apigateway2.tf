module "apigateway" {
    source = "./modules/apigateway"
    api_name = "steveAPI"
    stages = {"prod"="", "preProd"="preProd"}
    domain_name = "api.surepol.com"
    regional_certificate_arn = "arn:aws:acm:eu-west-2:717279690473:certificate/8aac3c0d-fdb2-4d0d-ab7c-e46a1a5e34db"
    zone_id = "Z00347011S1MYBDO0EHRL"

    api_routes = [
        {path_part = "hello-world", http_method = "GET", lambda_arn = module.hello_world_lambda.lambda_arn},
        {path_part = "goodbye-world", http_method = "GET", lambda_arn = module.goodbye_world_lambda.lambda_arn}
    ]
}
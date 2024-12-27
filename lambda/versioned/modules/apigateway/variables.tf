
variable "api_name" {
  description = "Name of API"
  type        = string
}

variable "stages" {
  description = "API Gatewat Stages"
  type        = map(string)
}

variable "domain_name" {
  description = "Route53 API Domain Name"
  type        = string
}

variable "regional_certificate_arn" {
    description = "Route53 API Domain Name"
    type        = string
}

variable "zone_id" {
    description = "Route 53 ZoneID"
    type = string
}


variable "api_routes" {
  description = "List of API Gateway routes with associated HTTP method and Lambda ARN"
  type = list(
    object({
      path_part   = string
      http_method = string
      lambda_arn  = string
    })
  )
}
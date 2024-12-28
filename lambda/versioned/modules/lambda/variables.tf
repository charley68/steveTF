

variable "role_arn" {
  description = "IAM Role ARN for the Lambda function."
  type        = string
}

variable "handler" {
  description = "The handler for the Lambda function."
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "runtime" {
  description = "The runtime for the Lambda function."
  type        = string
  default     = "python3.9"
}

variable "tags" {
  description = "Tags to apply to the Lambda function."
  type        = map(string)
  default     = {}
}

variable "alias_name" {
  description = "Name of the Lambda alias."
  type        = string
  default     = "staging"
}

variable "permission_statement_id" {
  description = "Unique statement ID for Lambda permissions."
  type        = string
  default     = "AllowExecutionFromAPIGateway"
}

variable "principal" {
  description = "Principal entity allowed to invoke the Lambda function."
  type        = string
  default     = "apigateway.amazonaws.com"
}



variable "environment_vars" {
  description = "Optional env vars to set for the lambda"
  type = map(string)
  default = {}
}



variable "functions" {
  description = "List of functions"
  type = list(
    object({
      function_name   = string
      function_src = string
      gateway_arn  = string
    })
  )
}
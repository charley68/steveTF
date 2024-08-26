
resource "aws_iam_role" "APIRole" {
  name = "APIRole"

  # Enable the role to get AWS credentials
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
                    "lambda.amazonaws.com",
                    "apigateway.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "sqs_attachment" {
  role       = aws_iam_role.APIRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}


resource "aws_iam_role_policy_attachment" "lambda_sqs_attachment" {
  role = aws_iam_role.APIRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_instance_profile" "steve_profile" {
  name = "APIRole"
  role = aws_iam_role.APIRole.name
}


data "aws_caller_identity" "current" {}

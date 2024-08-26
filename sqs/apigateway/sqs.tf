

# This workaround is due to a bug where sometimes the queue fails to create
# as role isnt ready yet.  This forces a 60 second wait after role is created
# before the queue is created.
resource "time_sleep" "wait_10_seconds" {
  depends_on = [aws_iam_role.APIRole]

  create_duration = "10s"
}


resource "aws_sqs_queue" "terraform_queue" {

  depends_on = [  time_sleep.wait_10_seconds ]
  name = var.SQSQueue


  # This is the access policy itself on who or what can access this queue
  policy = jsonencode({
    
    "Version": "2012-10-17",
    "Id": "__default_policy_ID",
    "Statement": [
        {
        "Sid": "__owner_statement",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.APIRole.name}"
        },
        "Action": "SQS:*",
        "Resource": "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${var.SQSQueue}"
        }]
  })

  tags = local.tags
}

resource "aws_iam_role" "SteveEC2Role" {
  name = "SteveEC2Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_attachment" {
  role       = aws_iam_role.SteveEC2Role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "steve_profile" {
  name = "steve_profile"
  role = aws_iam_role.SteveEC2Role.name
}

resource "aws_instance" "web" {
  ami           = "ami-008ea0202116dbc56"
  associate_public_ip_address = true
  instance_type = "t2.micro"
  iam_instance_profile = "steve_profile"

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_instance" "web2" {
  ami           = "ami-008ea0202116dbc56"
  associate_public_ip_address = true
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorldNoRole"
  }
}


variable "bucket" {
    type = string
    default = "steve-app-bucket"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "pull_source_policy" {
  bucket = var.bucket

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.SteveEC2Role.name}"
        },
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::${var.bucket}",
          "arn:aws:s3:::${var.bucket}/*",
        ]
      }
    ]
  })
}

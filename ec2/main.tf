

output "ec2" {
 value = { for k, v in aws_instance.steve1 : k => v }
}

resource "aws_instance" "steve1" {
  ami                     = "ami-008ea0202116dbc56"
  instance_type           = "t2.micro"
}

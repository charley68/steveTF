
resource "aws_instance" "steve1" {
  //ami                     = "ami-008ea0202116dbc56"
  ami = "ami-07c1b39b7b3d2525d"
  instance_type           = "t2.micro"

  security_groups = [aws_security_group.ec2.name]

  user_data = <<EOF
#!/bin/bash

apt-get update -y
apt-get install -y apache2

echo "Hello, World from Terraform!" > /var/www/html/index.html
EOF

  # Example tags
  tags = {
    Name = "terraform-example-instance"
  }
}

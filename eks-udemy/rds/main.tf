# Devteds Course Materials. Find more at https://www.devteds.com/kubernetes-course-aws-eks-terraform


data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "bookstore"
  username             = var.apidb_user
  password             = var.apidb_pass
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible = true

  multi_az  = false

  depends_on = [aws_db_subnet_group.mysql]

  vpc_security_group_ids = [aws_security_group.mysql.id]
  db_subnet_group_name = aws_db_subnet_group.mysql.id
}

resource "aws_db_subnet_group" "mysql" {
  name       = "bookstore"
  subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnets
}

resource "aws_security_group" "mysql" {
  name        = "allow_all_mysql"
  description = "Allow MYSQL inbound traffic on 3306"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description      = "MySQL from anywhere"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
  }
}



# Devteds Course Materials. Find more at https://www.devteds.com 
# K8S Course: https://www.devteds.com/kubernetes-course-aws-eks-terraform
# Course on Udemy: https://www.udemy.com/course/kubernetes-on-aws-eks-hands-on-guide-for-devs-devops
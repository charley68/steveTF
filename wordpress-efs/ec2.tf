data "aws_ami" "amzn_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  credentials = {
    db_name        = aws_ssm_parameter.db_name.value
    db_username    = aws_ssm_parameter.db_username.value
    db_password    = aws_ssm_parameter.db_password.value
    db_host        = aws_rds_cluster.wordpress_db_cluster.endpoint
    wp_title       = aws_ssm_parameter.wp_title.value
    wp_username    = aws_ssm_parameter.wp_username.value
    wp_password    = aws_ssm_parameter.wp_password.value
    wp_email       = aws_ssm_parameter.wp_email.value
    site_url       = aws_ssm_parameter.site_url.value
    region         = var.region
    file_system_id = aws_efs_file_system.wordpress_fs.id
  }
}

resource "aws_launch_template" "wordpress_lt" {
  name          = "wordpress_lt"
  description   = "Launch Template for the WordPress instances"
  image_id      = data.aws_ami.amzn_linux_2.id  #  var.ami
  instance_type = var.instance
  key_name      = "myKey-key"
  user_data     = base64encode(templatefile("./scripts/bootstrap.sh", local.credentials))

  iam_instance_profile {
    name = aws_iam_instance_profile.parameter_store_profile.name
  }

  network_interfaces {
    security_groups = [aws_security_group.allow_ssh.id]
  }
}

resource "aws_autoscaling_group" "wordpress_asg" {
  name             = "wordpress-asg"
  desired_capacity = 1
  min_size         = 1
  max_size         = 3

  vpc_zone_identifier = aws_db_subnet_group.rds_subnet_group
  target_group_arns   = [aws_lb_target_group.wordpress_tg.arn]
  health_check_type   = "ELB"


  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "wordpress-asg"
    propagate_at_launch = true
  }
}


# Generate new private key 
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
}

# Generate a key-pair with above key
resource "aws_key_pair" "deployer" {
  key_name   = "myKey-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

# Saving Key Pair
resource "null_resource" "save_key_pair"  {
	provisioner "local-exec" {
	    command = "echo  ${tls_private_key.my_key.private_key_pem} > mykey.pem"
  	}
}



# Devteds Course Materials. Find more at https://www.devteds.com/kubernetes-course-aws-eks-terraform


data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate"
  }
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name            = var.cluster_name
  cluster_version = "1.27"
  region          = var.region

  tags = {
    DevtedsStack      = local.name
    DevtedsStackName  = "EKS"
    DevtedsOrg        = "Devteds Courses"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

module "eks" {
  source    = "terraform-aws-modules/eks/aws"
  version   = "19.15.3"

  cluster_name              = local.name
  cluster_version           = local.cluster_version

  vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
  # subnet_ids                = data.terraform_remote_state.vpc.outputs.public_subnets
  subnet_ids                = data.terraform_remote_state.vpc.outputs.public_subnets
  
  control_plane_subnet_ids  = data.terraform_remote_state.vpc.outputs.intra_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa = true
  
  create_kms_key = false
  enable_kms_key_rotation = false
  cluster_encryption_config = {}

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m5.large"]
    # instance_types = ["t2.micro", "t2.medium", "t3.small", "t3.micro"]
    iam_role_attach_cni_policy = true
    # vpc_security_group_ids                = [aws_security_group.additional.id]
    # subnet_ids                = data.terraform_remote_state.vpc.outputs.private_subnets
  }
  
  eks_managed_node_groups = {    
    default_node_group = {
      use_custom_launch_template = false
      disk_size = 50
      # HOW MANY EC2 INSTANCES TO USE AS WORKER NODES (2)
      desired_size = 2 
      # remote_access = {
      #   ec2_ssh_key               = module.key_pair.key_pair_name
      #   source_security_group_ids = [aws_security_group.remote_access.id]
      # }
    }
  }

  tags = local.tags
}

resource "aws_security_group" "remote_access" {
  name_prefix = "${local.name}-remote-access"
  description = "Allow remote SSH from anywhere"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags, { Name = "${local.name}-remote-ssh" })
}

# Optional for remote access to worker nodes
module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name_prefix    = local.name
  create_private_key = true

  tags = local.tags
}
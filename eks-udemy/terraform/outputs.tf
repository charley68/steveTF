output "azs" {
  description = "Availability Zones"
  value   = module.vpc.azs
}

output "vpc_id" {
  description = "VPC ID"
  value   = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet ids"
  value = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet ids"
  value = module.vpc.public_subnets
}

output "intra_subnets" {
  description = "Intra subnet ids"
  value = module.vpc.intra_subnets
}


output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "aws_auth_configmap_yaml" {
  description = "Formatted yaml output for base aws-auth configmap containing roles used in cluster node groups/fargate profiles"
  value       = module.eks.aws_auth_configmap_yaml
}


output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.eks.cluster_platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster. CREATING | ACTIVE | DELETING | FAILED"
  value       = module.eks.cluster_status
}

output "cluster_primary_security_group_id" {
  description = "Cluster SG that was created by Amazon EKS for the cluster. Managed node groups use this SG for ControlPlan-to-DataPlane communication"
  value       = module.eks.cluster_primary_security_group_id
}

output "cluster_security_group_arn" {
  description = "Cluster SG ARN"
  value       = module.eks.cluster_security_group_arn
}

output "cluster_security_group_id" {
  description = "Cluster SG ID"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_arn" {
  description = "Shared SG ARN"
  value       = module.eks.node_security_group_arn
}

output "node_security_group_id" {
  description = "Shared SG ID"
  value       = module.eks.node_security_group_id
}

output "cluster_tls_certificate_sha1_fingerprint" {
  description = "SHA1 fingerprint of the pub-key of the cluster's certificate"
  value       = module.eks.cluster_tls_certificate_sha1_fingerprint
}


# IAM Role

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.eks.cluster_iam_role_unique_id
}

# CloudWatch Log Group

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = module.eks.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = module.eks.cloudwatch_log_group_arn
}



# Devteds Course Materials. Find more at https://www.devteds.com 
# K8S Course: https://www.devteds.com/kubernetes-course-aws-eks-terraform
# Course on Udemy: https://www.udemy.com/course/kubernetes-on-aws-eks-hands-on-guide-for-devs-devops

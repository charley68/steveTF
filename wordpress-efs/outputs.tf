output "public_ip" {
  value = aws_instance.wordpress.public_ip
}

# We need to update the docker image config with this endpoint for wordpress somehow ??
output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}
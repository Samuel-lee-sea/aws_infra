output "webapp_public_ip" {
  description = "Public IP address of the WebApp instance"
  value       = aws_eip.webapp_eip.public_ip
}

output "mysql_private_ip" {
  description = "Private IP address of the MySQL instance"
  value       = aws_instance.mysql.private_ip
}
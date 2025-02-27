variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "instance"
  type        = string
  default     = "t2.micro"
}

variable "webapp_ami_id" {
  description = "WebApp EC2 AMI ID"
  type        = string
}

variable "mysql_ami_id" {
  description = "MySQL EC2 AMI ID"
  type        = string
}

variable "database_password" {
  description = "database_password"
  type        = string
}

variable "database_username" {
  description = "database_username"
  type        = string
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateway"
  type        = bool
  default     = false
}

variable "webapp_secret_key" {
  description = "Secret key for the webapp"
  type        = string
  sensitive   = true
}
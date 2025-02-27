resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name_prefix = "deployer-key-"
  public_key      = tls_private_key.deployer.public_key_openssh

  lifecycle {
    create_before_destroy = true
  }
}

resource "local_file" "private_key" {
  content         = tls_private_key.deployer.private_key_pem
  filename        = "${path.module}/deployer-key.pem"
  file_permission = "0400"
}
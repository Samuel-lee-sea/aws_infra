resource "aws_instance" "webapp" {
  ami               = var.webapp_ami_id
  availability_zone = "us-west-2b"
  instance_type     = var.instance_type
  subnet_id         = aws_subnet.public_subnet.id
  key_name          = aws_key_pair.deployer.key_name
  security_groups   = [aws_security_group.webapp_sg.id]

  user_data = <<-EOF
      #!/bin/bash
      set -e

      MYSQL_IP="${aws_instance.mysql.private_ip}"

      sudo sed -i '/SPRING_DATASOURCE_URL/d' /etc/environment
      sudo sed -i '/DB_USERNAME/d' /etc/environment
      sudo sed -i '/DB_PASSWORD/d' /etc/environment

      echo "export SPRING_DATASOURCE_URL=jdbc:mysql://$MYSQL_IP:3306/recommend?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true" | sudo tee -a /etc/environment
      echo "export DB_USERNAME=${var.database_username}" | sudo tee -a /etc/environment
      echo "export DB_PASSWORD=${var.database_password}" | sudo tee -a /etc/environment
      echo "export DB_IP=$MYSQL_IP" | sudo tee -a /etc/environment
      
      sudo chmod 644 /etc/environment
      source /etc/environment

      echo "Environment variables:"
      env | grep -E 'SPRING_DATASOURCE_URL|DB_USERNAME|DB_PASSWORD'

      sudo chown ubuntu:ubuntu /home/ubuntu/webapp.jar
      chmod +x /home/ubuntu/webapp.jar
      sudo touch /home/ubuntu/webapp.log
      sudo chown ubuntu:ubuntu /home/ubuntu/webapp.log
      sudo chmod 644 /home/ubuntu/webapp.log
      sudo chown -R ubuntu:ubuntu /home/ubuntu/
      sudo chmod -R 755 /home/ubuntu/

      sudo pkill -f "webapp.jar" || true
      echo "sleep before $(date)"
      echo "$(whoami)"
      sudo -u ubuntu nohup java -jar /home/ubuntu/webapp.jar > /home/ubuntu/webapp.log 2>&1 &
      echo "sleep after WebApp started successfully at $(date)"
  EOF

  tags = {
    Name = "WebApp"
  }
}

resource "aws_eip" "webapp_eip" {
  instance = aws_instance.webapp.id
  domain   = "vpc"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_internet_gateway.igw,
    aws_instance.webapp
  ]

  tags = {
    Name       = "WebApp-EIP"
    AutoDelete = "true"
  }
}

resource "aws_instance" "mysql" {
  ami               = var.mysql_ami_id
  availability_zone = "us-west-2a"
  instance_type     = var.instance_type
  subnet_id         = aws_subnet.private_subnet.id
  key_name          = aws_key_pair.deployer.key_name
  security_groups   = [aws_security_group.mysql_sg.id]

  user_data = <<-EOF
      #!/bin/bash

      echo "Updating MySQL user permissions..."

      mysql -u root -p'${var.database_password}' -e "
        DROP USER IF EXISTS '${var.database_username}'@'10.1.0.200';
        CREATE USER '${var.database_username}'@'%' IDENTIFIED BY '${var.database_password}';
        GRANT ALL PRIVILEGES ON recommend.* TO '${var.database_username}'@'%';
        FLUSH PRIVILEGES;
      "
   EOF

  tags = {
    Name = "MySQL"
  }
}

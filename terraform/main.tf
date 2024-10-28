provider "aws" {
  region = "us-east-1"
}

# Define the Key Pair
resource "aws_key_pair" "terraform_key_pair" {
  key_name   = "terraform_key_pair"
  public_key = file("~/.ssh/${path.module}/terraform_key.pub")
}

# Create a Security Group for Web, Custom TCP, SSH Access, and NodePort 30000
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow inbound web traffic, SSH access, and NodePort for K8s"

  # HTTP access
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom TCP ports
  ingress {
    description = "Allow Custom TCP Ports"
    from_port   = 8081
    to_port     = 8083
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort 30000 access for Kubernetes web application
  ingress {
    description = "Allow NodePort 30000 for web application"
    from_port   = 30000
    to_port     = 30000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define an EC2 Instance for Running Kind K8s Cluster with Instance Type t2.medium
resource "aws_instance" "app_server" {
  ami           = "ami-0cff7528ff583bf9a" # Amazon Linux 2 AMI
  instance_type = "t2.medium"
  key_name      = aws_key_pair.terraform_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  tags = {
    Name = "assignment2-bhupendra"
  }

  # Configure Docker Installation in EC2 Instance
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              EOF
}

# ECR Repositories for the Applications
resource "aws_ecr_repository" "webapp" {
  name = "assignment2-webapp"
}

resource "aws_ecr_repository" "mysql" {
  name = "assignment2-mysql"
}

# Output Public IP and ECR URLs
output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "webapp_ecr_repository_url" {
  value = aws_ecr_repository.webapp.repository_url
}

output "mysql_ecr_repository_url" {
  value = aws_ecr_repository.mysql.repository_url
}

# output "mysql_ecr_repository_url" {
#   value = aws_ecr_repository.mysql.repository_url
# }



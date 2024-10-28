provider "aws" {
  region = "us-east-1" # Change this to your preferred region
}

resource "aws_instance" "app_server" {
  ami           = "ami-0cff7528ff583bf9a" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.assignment1_key_pair.key_name # Updated key pair reference

  vpc_security_group_ids = [aws_security_group.allow_web.id]

  tags = {
    Name = "assignment1-bhupendra"
  }

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

resource "aws_key_pair" "assignment1_key_pair" {
  key_name   = "assignment1_key_pair"             # Name of the key pair in AWS
  public_key = file("${path.module}/assignment1.pub") # Corrected path to the public key file
}


resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow inbound web traffic"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom TCP"
    from_port   = 8081
    to_port     = 8083
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "webapp" {
  name = "assignment1-webapp" 
}

resource "aws_ecr_repository" "mysql" {
  name = "assignment1-mysql" 
}


output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "webapp_ecr_repository_url" {
  value = aws_ecr_repository.webapp.repository_url
}

output "mysql_ecr_repository_url" {
  value = aws_ecr_repository.mysql.repository_url
}



# this is for testing purpose

# I have added this to test the video










# provider "aws" {
#   region = "us-east-1" # Change this to your preferred region
# }

# resource "aws_instance" "app_server" {
#   ami           = "ami-0cff7528ff583bf9a" # Amazon Linux 2 AMI
#   instance_type = "t2.micro"
#   key_name      = aws_key_pair.assignment1_key_pair.key_name # Updated key pair reference

#   vpc_security_group_ids = [aws_security_group.web_sg.id]  # Updated security group reference

#   tags = {
#     Name = "assignment1-bhupendra"
#   }

#   user_data = <<-EOF
#               #!/bin/bash
#               sudo yum update -y
#               sudo amazon-linux-extras install docker -y
#               sudo service docker start
#               sudo usermod -a -G docker ec2-user
#               sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#               sudo chmod +x /usr/local/bin/docker-compose
#               EOF
# }

# resource "aws_key_pair" "assignment1_key_pair" {
#   key_name   = "assignment1_key_pair"             # Name of the key pair in AWS
#   public_key = file("${path.module}/assignment1.pub") # Corrected path to the public key file
# }

# # Updated security group for the web server
# resource "aws_security_group" "web_sg" {
#   name        = "web-server-sg"
#   description = "Allow HTTP and SSH inbound traffic"

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  # For security, restrict this to your IP
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_ecr_repository" "webapp" {
#   name = "assignment1-webapp" 
# }

# resource "aws_ecr_repository" "mysql" {
#   name = "assignment1-mysql" 
# }

# output "instance_public_ip" {
#   value = aws_instance.app_server.public_ip
# }

# output "webapp_ecr_repository_url" {
#   value = aws_ecr_repository.webapp.repository_url
# }

# output "mysql_ecr_repository_url" {
#   value = aws_ecr_repository.mysql.repository_url
# }

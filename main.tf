terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.38.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}


data "aws_subnet_ids" "example" {
  vpc_id = "vpc-063ed755bdbe0ecbb" # ID da sua VPC
}


resource "aws_instance" "ansible_ec2" {
  ami           = "ami-0c02fb55956c7d316" # AMI ID para Amazon Linux 2 na região us-east-1
  instance_type = "t2.micro"
  key_name      = "syslog_key" # Substitua pelo nome da sua chave SSH existente na AWS

  vpc_security_group_ids = [
    "sg-0ff52c0727c0711d8" # Substitua pelo ID do seu Security Group "ssh_cluster"
  ]

  subnet_id = tolist(data.aws_subnet_ids.example.ids)[0] # Substitua pelo ID de uma subnet na sua VPC "VPC-ECS"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install ansible2 -y
              EOF

  tags = {
    Name = "SyslogSRV"
  }

}

output "instance_ip" {
  value = aws_instance.ansible_ec2.public_ip
}

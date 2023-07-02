variable "vpc_id" {
  type    = string
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

resource "aws_security_group" "c8_ec2_sg" {
  name = "c8-ec2-sg"
  description = "Security Group for EC2 used to deploy a self-managed Camunda 8 instance"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH"
    protocol = "TCP"
    from_port = 22
    to_port = 22
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

output "c8_ec2_sg_id" {
  value = aws_security_group.c8_ec2_sg.id
}

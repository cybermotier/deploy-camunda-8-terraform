variable "subnet_id" {
  type = string
}

variable "c8_ec2_sg" {
  type = string
}

data "aws_security_group" "c8_ec2_sg" {
  # Managed by ec2_sg module
  id = var.c8_ec2_sg
}

resource "random_id" "main" {
  byte_length = 8
}

locals {
  unique_id = random_id.main.id
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "c8-ec2-access-key-${local.unique_id}"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "c8_ec2_access_key_pem" {
  depends_on = [aws_key_pair.generated_key]
  filename   = "${path.module}/c8_ec2_access_key_${local.unique_id}.pem"
  content    = tls_private_key.key.private_key_pem
  file_permission = "0400"
}

#resource "null_resource" "change_permission" {
#  depends_on = [local_file.c8_ec2_access_key_pem]
#  provisioner "local-exec" {
#    on_failure  = fail
#    command     = <<-EOT
#      $path = ".\ec2_access_key_${local.unique_id}.pem"
#      # Reset to remove explict permissions
#      icacls.exe $path /reset
#      # Give current user explicit read-permission
#      icacls.exe $path /GRANT:R "$($env:USERNAME):(R)"
#      # Disable inheritance and remove inherited permissions
#      icacls.exe $path /inheritance:r
#    EOT
#    interpreter = ["PowerShell", "-Command"]
#  }
#}

# ami => Amazon Linux 2 AMI user is ec2-user
# https://docs.aws.amazon.com/efs/latest/ug/nfs-automount-efs.html
resource "aws_instance" "c8_access_ec2" {
  # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
  ami             = "ami-09e2d756e7d78558d"
  security_groups = [data.aws_security_group.c8_ec2_sg.id]
  subnet_id       = var.subnet_id
  instance_type   = "t2.nano"
  key_name        = aws_key_pair.generated_key.key_name

  tags = {
    Name = "c8-access-ec2-${local.unique_id}"
  }

  user_data = <<EOF
#!/bin/bash
EOF
}

output "ssh_command" {
  value = "ssh -o StrictHostKeyChecking=accept-new -i ${local_file.c8_ec2_access_key_pem.filename} ec2-user@${aws_instance.c8_access_ec2.private_ip}"
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

module "c8_ec2_sg" {
  source = "./modules/ec2_sg"
  vpc_id = var.vpc_id
}

module "c8_ec2" {
  source    = "./modules/ec2"
  subnet_id = var.subnet_id
  c8_ec2_sg = module.c8_ec2_sg.c8_ec2_sg_id
}

output "ssh_command" {
  value = "${module.c8_ec2.ssh_command}"
}

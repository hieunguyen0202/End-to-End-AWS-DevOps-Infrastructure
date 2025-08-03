locals {
  tags = {
    project     = var.project
  }
}


resource "aws_key_pair" "bastion_key" {
  key_name   = var.key_name
  public_key = file("${path.module}/keypair/aj3-aws-infra-bastion-key.pub")
}


resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = aws_key_pair.bastion_key.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update && sudo apt install mysql-client -y
              EOF

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp2"
  }

  tags = merge(
      local.tags,
      {
        Name = var.instance_name
      }
  )
}

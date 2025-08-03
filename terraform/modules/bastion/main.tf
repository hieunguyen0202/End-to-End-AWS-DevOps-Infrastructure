locals {
  tags = {
    project     = var.project
  }
}


resource "local_sensitive_file" "private_key" {
  filename        = "${path.module}/keypair/ansible.pem"
  content         = file("${path.module}/keypair/aj3-aws-infra-bastion-key")
  file_permission = "0400"
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

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y software-properties-common",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt install -y ansible"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.module}/keypair/aj3-aws-infra-bastion-key")
      host        = self.public_ip
    }
  }

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

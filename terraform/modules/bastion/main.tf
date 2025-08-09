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
  vpc_security_group_ids      = var.bastion_security_group_id
  key_name                    = aws_key_pair.bastion_key.key_name
  associate_public_ip_address = true


  # Install tools on boot
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update system
    sudo apt update -y && sudo apt upgrade -y

    # Install MySQL CLI
    sudo apt install -y mysql-client

    # Install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws

    # Install Session Manager plugin (for ECS exec)
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
    sudo dpkg -i session-manager-plugin.deb
    rm -f session-manager-plugin.deb

    # Verify installs
    mysql --version
    aws --version
    session-manager-plugin --version
  EOF

  # Step 1: Upload required files to Bastion
  # provisioner "file" {
  #   source      = "${path.module}/keypair/ansible.pem"
  #   destination = "/home/ubuntu/ansible.pem"

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file("${path.module}/keypair/aj3-aws-infra-bastion-key")
  #     host        = self.public_ip
  #   }
  # }

  # provisioner "file" {
  #   source      = "${path.module}/keypair/playbook.yaml"
  #   destination = "/home/ubuntu/playbook.yaml"

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file("${path.module}/keypair/aj3-aws-infra-bastion-key")
  #     host        = self.public_ip
  #   }
  # }

  # provisioner "file" {
  #   source      = "${path.module}/keypair/index.html"
  #   destination = "/home/ubuntu/index.html"

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file("${path.module}/keypair/aj3-aws-infra-bastion-key")
  #     host        = self.public_ip
  #   }
  # }

  # provisioner "file" {
  #   source      = "${path.module}/keypair/nginx.conf.j2"
  #   destination = "/home/ubuntu/nginx.conf.j2"
  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file("${path.module}/keypair/aj3-aws-infra-bastion-key")
  #     host        = self.public_ip
  #   }
  # }

  # # Step 2: Install Ansible
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt update -y",
  #     "sudo apt install -y software-properties-common",
  #     "sudo apt-add-repository --yes --update ppa:ansible/ansible",
  #     "sudo apt install -y ansible"
  #   ]

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file("${path.module}/keypair/aj3-aws-infra-bastion-key")
  #     host        = self.public_ip
  #   }
  # }

  # # Step 3: Run Ansible Playbook targeting nginx instance
  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod 400 /home/ubuntu/ansible.pem",
  #     "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key /home/ubuntu/ansible.pem -T 300 -i '${aws_instance.nginx.private_ip},' /home/ubuntu/playbook.yaml"
  #   ]

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file("${path.module}/keypair/aj3-aws-infra-bastion-key")
  #     host        = self.public_ip
  #   }
  # }

  
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


# resource "aws_instance" "nginx" {
#   ami                         = var.ami_id
#   instance_type               = var.instance_type
#   subnet_id                   = var.nginx_subnet_id
#   vpc_security_group_ids      = var.nginx_security_group_id
#   key_name                    = aws_key_pair.bastion_key.key_name
#   associate_public_ip_address = false  # Private instance, access via bastion

#   root_block_device {
#     volume_size = var.volume_size
#     volume_type = "gp2"
#   }

#   tags = merge(
#     local.tags,
#     {
#       Name = var.nginx_instance_name
#     }
#   )
# }

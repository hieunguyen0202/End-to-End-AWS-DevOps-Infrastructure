# modules/bastion/main.tf

resource "aws_key_pair" "bastion_key" {
  key_name   = var.key_name
  public_key = file("${path.module}/keypair/aws-infra-01-key.pub")
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
              sudo apt-get install -y gnupg curl
              curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
                sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
                --dearmor
              echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
              sudo apt-get update
              sudo apt-get install -y mongodb-org
              mongosh --version
              EOF

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp2"
  }

  tags = {
    Name = var.instance_name
  }
}

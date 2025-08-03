locals {
  tags = {
    project     = var.project
  }
}

resource "aws_vpc" "main" {
    cidr_block           = var.cidr_block
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = merge(
    local.tags,
    {
      Name = var.vpc_name
    }
  )
}


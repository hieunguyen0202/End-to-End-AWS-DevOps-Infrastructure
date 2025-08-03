provider "aws" {
  region = var.region
}


resource "aws_resourcegroups_group" "resourcegroups_group" {
  name = "${var.project}-resource-group"

  resource_query {
    query = <<-JSON
      {
        "ResourceTypeFilters": [
          "AWS::AllSupported"
        ],
        "TagFilters": [
          {
            "Key": "project",
            "Values": ["${var.project}"]
          }
        ]
      }
    JSON
  }
}

module "network" {
  source               = "../../modules/network"
  vpc_name             = var.vpc_name
  cidr_block           = var.cidr_block
  project              = var.project
}
provider "aws" {
  region = var.region
}

# module "storage" {
#   source = "../modules/storage"
#   bucket_name         = var.bucket_name
#   dynamodb_table_name = var.dynamodb_table_name
#   environment         = var.environment
# }





bucket         = "aj3-aws-infra-project-s3-backend"
key            = "dev/terraform.tfstate"
region         = "ap-southeast-1"
encrypt        = true
dynamodb_table = "terraform-series-s3-backend"
role_arn       = "arn:aws:iam::143735903781:role/Aj3-Aws-Infra-ProjectS3BackendRole"

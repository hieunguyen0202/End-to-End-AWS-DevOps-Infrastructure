output "beanstalk_app_name" {
  description = "Elastic Beanstalk application name"
  value       = aws_elastic_beanstalk_application.app.name
}

output "beanstalk_env_name" {
  description = "Elastic Beanstalk environment name"
  value       = aws_elastic_beanstalk_environment.env.name
}

output "beanstalk_env_url" {
  description = "Elastic Beanstalk environment CNAME (DNS name)"
  value       = aws_elastic_beanstalk_environment.env.endpoint_url
}

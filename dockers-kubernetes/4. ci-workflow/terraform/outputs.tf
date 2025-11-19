output "application_name" {
  description = "Name of the Elastic Beanstalk application"
  value       = aws_elastic_beanstalk_application.app.name
}

output "environment_name" {
  description = "Name of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.app_env.name
}

output "environment_url" {
  description = "URL of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.app_env.endpoint_url
}

output "environment_cname" {
  description = "CNAME of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.app_env.cname
}

output "load_balancers" {
  description = "Load balancers associated with the environment"
  value       = aws_elastic_beanstalk_environment.app_env.load_balancers
}

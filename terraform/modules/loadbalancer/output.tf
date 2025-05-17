output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "alb_arn" {
  value = aws_lb.alb.arn
}

output "frontend_target_group_arn" {
  value = aws_lb_target_group.frontend.arn
}
output "backend_target_group_arn" {
  value = aws_lb_target_group.backend.arn
}
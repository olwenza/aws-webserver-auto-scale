output "aws_launch_template_id" {
  value = aws_launch_template.this.id
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}
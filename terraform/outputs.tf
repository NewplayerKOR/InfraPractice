# Terraform 실행 후 출력될 정보

output "instance_id" {
  description = "EC2 인스턴스 ID"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "EC2 인스턴스 공인 IP (Elastic IP)"
  value       = aws_eip.app_eip.public_ip
}

output "instance_private_ip" {
  description = "EC2 인스턴스 사설 IP"
  value       = aws_instance.app_server.private_ip
}

output "security_group_id" {
  description = "보안 그룹 ID"
  value       = aws_security_group.app_sg.id
}

output "ssh_connection_command" {
  description = "SSH 접속 명령어"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_eip.app_eip.public_ip}"
}

output "application_url" {
  description = "애플리케이션 URL"
  value       = "http://${aws_eip.app_eip.public_ip}:${var.app_port}/api/users/health"
}

output "ami_id" {
  description = "사용된 Ubuntu AMI ID"
  value       = data.aws_ami.ubuntu.id
}

output "initialization_log" {
  description = "초기화 로그 확인 명령어"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_eip.app_eip.public_ip} 'cat /var/log/user_data.log'"
}

# 설명:
# - terraform apply 후 이 정보들이 출력됨
# - SSH 접속 명령어와 애플리케이션 URL을 바로 확인 가능
# - outputs.tf의 값은 'terraform output' 명령어로 다시 확인 가능

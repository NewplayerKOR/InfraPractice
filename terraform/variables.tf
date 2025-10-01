# AWS 기본 설정
variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"  # 서울
}

variable "aws_profile" {
  description = "AWS CLI 프로파일 이름"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# EC2 인스턴스 설정
variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t2.micro"  # 프리티어
}

variable "instance_name" {
  description = "EC2 인스턴스 이름"
  type        = string
  default     = "back-app-server"
}

# SSH 키 설정
variable "key_name" {
  description = "EC2 SSH 접속용 키페어 이름"
  type        = string
  # terraform.tfvars에서 설정
}

# 네트워크 설정
variable "allowed_ssh_cidr" {
  description = "SSH 접속 허용 IP (본인 IP/32 권장)"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # 모든 IP 허용 (보안 주의!)
}

# 애플리케이션 설정
variable "app_port" {
  description = "애플리케이션 포트"
  type        = number
  default     = 8080
}

# Docker 설정
variable "docker_compose_version" {
  description = "Docker Compose 버전"
  type        = string
  default     = "2.24.5"
}

# 데이터베이스 설정 (환경변수로 전달)
variable "mysql_root_password" {
  description = "MySQL Root 비밀번호"
  type        = string
  sensitive   = true
}

variable "mysql_password" {
  description = "MySQL 사용자 비밀번호"
  type        = string
  sensitive   = true
}

# 설명:
# - sensitive = true: 민감한 정보는 로그에 표시되지 않음
# - default 값이 있으면 terraform.tfvars에서 생략 가능
# - key_name, 비밀번호는 반드시 terraform.tfvars에 설정 필요

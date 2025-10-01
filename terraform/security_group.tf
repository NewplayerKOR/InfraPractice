# 보안 그룹 (방화벽 규칙)
resource "aws_security_group" "app_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for Back application"
  
  # 인바운드 규칙 (외부 → 서버)
  
  # SSH (22) - 서버 접속용
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }
  
  # HTTP (80) - Nginx용 (나중에 사용)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # HTTPS (443) - SSL용 (나중에 사용)
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Application Port (8080) - Spring Boot 앱
  ingress {
    description = "Spring Boot Application"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # 아웃바운드 규칙 (서버 → 외부)
  # 모든 트래픽 허용 (Docker 이미지 다운로드 등)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.instance_name}-sg"
  }
}

# 설명:
# - ingress: 들어오는 트래픽 (인바운드)
# - egress: 나가는 트래픽 (아웃바운드)
# - 0.0.0.0/0: 모든 IP 허용
# - protocol "-1": 모든 프로토콜 허용
# 
# 보안 강화 방법:
# - SSH는 본인 IP만 허용하도록 변경 권장
# - allowed_ssh_cidr = ["본인공인IP/32"]

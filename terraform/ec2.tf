# EC2 인스턴스
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  # 보안 그룹 연결
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  
  # 루트 볼륨 (디스크) 설정
  root_block_device {
    volume_type           = "gp3"  # 최신 SSD (gp2보다 성능 좋음)
    volume_size           = 20     # 20GB (프리티어: 30GB까지 무료)
    delete_on_termination = true   # 인스턴스 삭제 시 볼륨도 삭제
    encrypted             = true   # 디스크 암호화
    
    tags = {
      Name = "${var.instance_name}-root-volume"
    }
  }
  
  # User Data: 인스턴스 시작 시 실행할 스크립트
  user_data = templatefile("${path.module}/user_data.sh", {})
  
  # 메타데이터 옵션 (보안 강화)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 강제 (보안)
    http_put_response_hop_limit = 1
  }
  
  # 태그
  tags = {
    Name = var.instance_name
  }
  
  # 인스턴스 생성 후 완료 메시지
  provisioner "local-exec" {
    command = "echo 'EC2 인스턴스가 생성되었습니다. IP: ${self.public_ip}'"
  }
}

# Elastic IP (고정 IP) - 선택사항
# 인스턴스를 재시작해도 IP가 바뀌지 않음
resource "aws_eip" "app_eip" {
  instance = aws_instance.app_server.id
  domain   = "vpc"
  
  tags = {
    Name = "${var.instance_name}-eip"
  }
  
  # 인스턴스가 생성된 후에 EIP 할당
  depends_on = [aws_instance.app_server]
}

# 설명:
# - ami: data.tf에서 조회한 Ubuntu 22.04 AMI 사용
# - gp3: 최신 SSD 타입 (gp2보다 저렴하고 빠름)
# - 20GB: 프리티어는 30GB까지 무료지만 20GB면 충분
# - user_data: user_data.sh 스크립트 자동 실행
# - IMDSv2: 메타데이터 보안 강화
# - Elastic IP: 고정 IP 할당 (도메인 연결 시 필요)
# 
# 프리티어 주의사항:
# - t2.micro: 월 750시간 무료 (1대 계속 실행 가능)
# - EBS: 30GB까지 무료
# - Elastic IP: 인스턴스에 연결되어 있으면 무료

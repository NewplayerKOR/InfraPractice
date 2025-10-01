# 최신 Ubuntu 22.04 LTS AMI 조회
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical (Ubuntu 공식)
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# 설명:
# - Ubuntu 22.04 LTS (Jammy Jellyfish) 최신 버전 자동 선택
# - AMI ID는 리전마다 다르므로 data source로 조회
# - owners: Canonical의 AWS 계정 ID
# - most_recent: 가장 최신 버전 선택

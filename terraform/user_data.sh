#!/bin/bash
set -e

# EC2 인스턴스 초기화 스크립트
# 이 스크립트는 EC2 인스턴스가 처음 시작될 때 자동으로 실행됩니다

echo "================================"
echo "인스턴스 초기화 시작"
echo "================================"

# 로그 파일 설정
LOG_FILE="/var/log/user_data.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "[$(date)] 시스템 업데이트 시작..."

# 1. 시스템 패키지 업데이트
apt-get update -y
apt-get upgrade -y

echo "[$(date)] 필수 패키지 설치 중..."

# 2. 필수 패키지 설치
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    vim \
    wget \
    unzip

echo "[$(date)] Docker 설치 중..."

# 3. Docker 공식 GPG 키 추가
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Docker 리포지토리 추가
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Docker 설치
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[$(date)] Docker 설정 중..."

# 6. Docker 서비스 시작 및 부팅 시 자동 시작 설정
systemctl start docker
systemctl enable docker

# 7. ubuntu 사용자를 docker 그룹에 추가 (sudo 없이 docker 명령 사용 가능)
usermod -aG docker ubuntu

echo "[$(date)] Docker Compose 설치 중..."

# 8. Docker Compose 최신 버전 설치 (v2는 플러그인으로 이미 설치됨)
# docker compose 명령어 사용 가능

echo "[$(date)] 애플리케이션 디렉토리 생성..."

# 9. 애플리케이션 디렉토리 생성
mkdir -p /home/ubuntu/app
chown -R ubuntu:ubuntu /home/ubuntu/app

# 10. 로그 디렉토리 생성
mkdir -p /var/log/back
chown -R ubuntu:ubuntu /var/log/back

echo "[$(date)] 타임존 설정..."

# 11. 타임존을 서울로 설정
timedatectl set-timezone Asia/Seoul

echo "[$(date)] 스왑 메모리 설정..."

# 12. 스왑 파일 생성 (t2.micro는 메모리가 작아서 스왑 필요)
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo "스왑 메모리 2GB 생성 완료"
fi

echo "[$(date)] 방화벽 설정..."

# 13. UFW 방화벽 설정 (선택사항)
ufw --force enable
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 8080/tcp  # Application

echo "[$(date)] Docker 버전 확인..."

# 14. 설치 확인
docker --version
docker compose version

echo "[$(date)] 초기화 완료!"
echo "================================"
echo "설치 완료 정보"
echo "================================"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker compose version)"
echo "Timezone: $(timedatectl | grep 'Time zone')"
echo "Swap: $(free -h | grep Swap)"
echo "================================"

# 15. 완료 표시 파일 생성
touch /home/ubuntu/initialization_complete
chown ubuntu:ubuntu /home/ubuntu/initialization_complete

echo "초기화 스크립트 완료. 로그 위치: $LOG_FILE"

# 설명:
# - set -e: 에러 발생 시 스크립트 중단
# - exec > >(tee -a $LOG_FILE): 모든 출력을 로그 파일에 저장
# - usermod -aG docker ubuntu: ubuntu 사용자가 sudo 없이 docker 명령 사용 가능
# - 스왑 메모리: t2.micro는 1GB RAM이라 부족할 수 있어서 2GB 스왑 추가
# - UFW: Ubuntu 기본 방화벽 (보안그룹과 중복이지만 추가 보안)

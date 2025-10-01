#!/bin/bash

# 빠른 시작 스크립트
# 사용법: ./start.sh

set -e

echo "================================"
echo "Back Application 시작 스크립트"
echo "================================"
echo ""

# .env 파일 존재 확인
if [ ! -f .env ]; then
    echo "❌ .env 파일이 없습니다."
    echo "📝 .env.example을 복사하여 .env 파일을 생성합니다..."
    cp .env.example .env
    echo "✅ .env 파일이 생성되었습니다."
    echo ""
    echo "⚠️  .env 파일을 편집하여 실제 비밀번호를 설정하세요:"
    echo "   - MYSQL_ROOT_PASSWORD"
    echo "   - MYSQL_PASSWORD"
    echo "   - DB_PASSWORD (MYSQL_PASSWORD와 동일하게)"
    echo ""
    read -p "편집을 완료했습니까? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "종료합니다. .env 파일을 편집한 후 다시 실행하세요."
        exit 1
    fi
fi

echo "🔍 Docker 및 Docker Compose 확인 중..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker가 설치되어 있지 않습니다."
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose가 설치되어 있지 않습니다."
    exit 1
fi

echo "✅ Docker 확인 완료"
echo ""

echo "🏗️  이미지 빌드 및 컨테이너 시작 중..."
docker-compose up -d --build

echo ""
echo "⏳ 서비스가 준비될 때까지 대기 중..."
sleep 10

echo ""
echo "🏥 헬스 체크 중..."
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:8080/api/users/health > /dev/null 2>&1; then
        echo "✅ 애플리케이션이 정상적으로 시작되었습니다!"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT+1))
    echo "   대기 중... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "❌ 애플리케이션 시작에 실패했습니다."
    echo "📋 로그를 확인하세요: docker-compose logs -f"
    exit 1
fi

echo ""
echo "================================"
echo "✨ 배포 완료!"
echo "================================"
echo ""
echo "📍 접속 정보:"
echo "   - API 엔드포인트: http://localhost:8080/api/users"
echo "   - 헬스 체크: http://localhost:8080/api/users/health"
echo "   - Actuator: http://localhost:8080/actuator/health"
echo ""
echo "📝 유용한 명령어:"
echo "   - 로그 확인: docker-compose logs -f"
echo "   - 서비스 중지: docker-compose down"
echo "   - 상태 확인: docker-compose ps"
echo ""
echo "🧪 API 테스트:"
echo "   curl http://localhost:8080/api/users/health"
echo ""

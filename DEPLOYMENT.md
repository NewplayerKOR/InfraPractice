# 배포 가이드

## 사전 준비

### 필수 설치 항목
- Docker (20.10 이상)
- Docker Compose (v2.0 이상)
- Git

## 로컬 환경에서 배포

### 1단계: 프로젝트 클론
```bash
git clone <repository-url>
cd back
```

### 2단계: 환경변수 설정
```bash
# .env.example을 복사하여 .env 생성
cp .env.example .env

# .env 파일을 편집기로 열어서 실제 값 입력
vi .env  # 또는 nano .env
```

**.env 파일 예시:**
```env
MYSQL_ROOT_PASSWORD=your_secure_password
MYSQL_DATABASE=backdb
MYSQL_USER=backuser
MYSQL_PASSWORD=your_user_password

SPRING_PROFILE=prod
DB_HOST=mysql
DB_PORT=3306
DB_NAME=backdb
DB_USERNAME=backuser
DB_PASSWORD=your_user_password

SERVER_PORT=8080
JAVA_OPTS=-Xms512m -Xmx1024m -XX:+UseG1GC
```

**⚠️ 주의사항:**
- `DB_USERNAME`과 `MYSQL_USER`는 동일해야 합니다
- `DB_PASSWORD`와 `MYSQL_PASSWORD`는 동일해야 합니다
- 실제 운영 환경에서는 강력한 비밀번호를 사용하세요

### 3단계: Docker Compose로 실행
```bash
# 백그라운드에서 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 특정 서비스 로그만 확인
docker-compose logs -f app
docker-compose logs -f mysql
```

### 4단계: 서비스 확인
```bash
# 헬스 체크
curl http://localhost:8080/api/users/health

# 컨테이너 상태 확인
docker-compose ps

# 예상 출력:
# NAME         COMMAND                  SERVICE   STATUS    PORTS
# back-app     "sh -c 'java $JAVA_O…"   app       healthy   0.0.0.0:8080->8080/tcp
# back-mysql   "docker-entrypoint.s…"   mysql     healthy   0.0.0.0:3306->3306/tcp
```

### 5단계: API 테스트
```bash
# 사용자 생성
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "phone": "010-1234-5678"
  }'

# 모든 사용자 조회
curl http://localhost:8080/api/users

# 특정 사용자 조회
curl http://localhost:8080/api/users/1
```

## 서비스 관리

### 서비스 중지
```bash
# 컨테이너 중지 (데이터 유지)
docker-compose stop

# 컨테이너 중지 및 제거 (데이터 유지)
docker-compose down

# 컨테이너, 네트워크, 볼륨까지 모두 제거
docker-compose down -v
```

### 서비스 재시작
```bash
# 전체 재시작
docker-compose restart

# 특정 서비스만 재시작
docker-compose restart app
```

### 로그 확인
```bash
# 실시간 로그
docker-compose logs -f

# 마지막 100줄만 확인
docker-compose logs --tail=100

# 특정 시간 이후 로그
docker-compose logs --since="2025-10-01T10:00:00"
```

### 데이터베이스 접속
```bash
# MySQL 컨테이너 접속
docker-compose exec mysql mysql -u backuser -p

# 비밀번호 입력 후 사용
USE backdb;
SHOW TABLES;
SELECT * FROM users;
```

## AWS EC2 환경 배포 (예정)

### 사전 준비
1. EC2 인스턴스 생성 (Ubuntu 22.04 LTS 권장)
2. 보안 그룹 설정:
   - SSH (22)
   - HTTP (80)
   - HTTPS (443)
   - Custom (8080) - 애플리케이션 포트

### 배포 스크립트
```bash
# EC2 인스턴스 접속
ssh -i your-key.pem ubuntu@your-ec2-ip

# Docker 설치
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
newgrp docker

# 프로젝트 클론 및 배포
git clone <repository-url>
cd back
cp .env.example .env
vi .env  # 환경변수 설정

# 실행
docker-compose up -d

# 방화벽 설정 (선택사항)
sudo ufw allow 8080/tcp
sudo ufw enable
```

## 트러블슈팅

### 포트 충돌
```bash
# 포트 사용 중인 프로세스 확인
sudo lsof -i :8080
sudo lsof -i :3306

# 프로세스 종료
sudo kill -9 <PID>

# 또는 .env에서 다른 포트 사용
SERVER_PORT=8081
```

### 컨테이너가 계속 재시작됨
```bash
# 로그 확인
docker-compose logs app

# 일반적인 원인:
# 1. 데이터베이스 연결 실패 - .env 파일의 DB 설정 확인
# 2. 메모리 부족 - JAVA_OPTS 조정
# 3. 포트 충돌 - 다른 포트 사용
```

### 데이터베이스 연결 실패
```bash
# MySQL 컨테이너 상태 확인
docker-compose ps mysql

# MySQL 로그 확인
docker-compose logs mysql

# 연결 테스트
docker-compose exec app ping mysql
```

### 이미지 빌드 실패
```bash
# 캐시 없이 다시 빌드
docker-compose build --no-cache

# Gradle 캐시 삭제
./gradlew clean
```

## 보안 권장사항

### 운영 환경
1. **강력한 비밀번호 사용**
   - 최소 16자 이상
   - 대소문자, 숫자, 특수문자 혼합

2. **환경변수 관리**
   - `.env` 파일은 절대 Git에 커밋하지 않기
   - AWS Secrets Manager 또는 환경변수로 관리

3. **네트워크 보안**
   - 불필요한 포트는 닫기
   - HTTPS 사용 (Nginx + Let's Encrypt)

4. **데이터베이스 보안**
   - Root 계정 직접 사용 금지
   - 정기적인 백업

## 모니터링

### 헬스체크
```bash
# 애플리케이션 헬스
curl http://localhost:8080/api/users/health

# Spring Boot Actuator
curl http://localhost:8080/actuator/health
```

### 리소스 사용량
```bash
# 컨테이너 리소스 확인
docker stats

# 디스크 사용량
docker system df
```

## 백업 및 복구

### 데이터베이스 백업
```bash
# 백업
docker-compose exec mysql mysqldump -u backuser -p backdb > backup_$(date +%Y%m%d).sql

# 복구
docker-compose exec -T mysql mysql -u backuser -p backdb < backup_20251001.sql
```

### 볼륨 백업
```bash
# 볼륨 목록 확인
docker volume ls

# 볼륨 백업
docker run --rm \
  -v back_mysql-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/mysql-data-backup.tar.gz -C /data .
```

## 다음 단계
- [ ] CI/CD 파이프라인 구축 (GitHub Actions)
- [ ] 무중단 배포 (Blue-Green 또는 Rolling)
- [ ] 모니터링 시스템 (Prometheus + Grafana)
- [ ] 로그 수집 (ELK Stack)

# InfraPractice
Infra관련 기능 연습 레포지터리

## 프로젝트 개요
Spring Boot 3.5.6 기반의 User 관리 REST API

## 기술 스택
- **Language**: Java 21
- **Framework**: Spring Boot 3.5.6
- **Build Tool**: Gradle 8.14.3
- **Database**: H2 (dev), MySQL 8.0 (prod)
- **ORM**: Spring Data JPA
- **Container**: Docker, Docker Compose

## 프로젝트 구조
```
src/
├── main/
│   ├── java/com/back/
│   │   ├── controller/     # REST API 컨트롤러
│   │   ├── service/        # 비즈니스 로직
│   │   ├── repository/     # 데이터 액세스
│   │   ├── entity/         # JPA 엔티티
│   │   ├── dto/            # 데이터 전송 객체
│   │   └── exception/      # 예외 처리
│   └── resources/
│       ├── application.yml         # 공통 설정
│       ├── application-dev.yml     # 개발 환경
│       └── application-prod.yml    # 운영 환경
└── test/
```

## API 엔드포인트

### User API
- `GET /api/users` - 모든 사용자 조회
- `GET /api/users/{id}` - ID로 사용자 조회
- `GET /api/users/username/{username}` - 사용자명으로 조회
- `POST /api/users` - 사용자 생성
- `PUT /api/users/{id}` - 사용자 수정
- `DELETE /api/users/{id}` - 사용자 삭제
- `GET /api/users/health` - 헬스 체크

### 요청/응답 예시

**사용자 생성 (POST /api/users)**
```json
{
  "username": "testuser",
  "email": "test@example.com",
  "phone": "010-1234-5678"
}
```

**응답**
```json
{
  "id": 1,
  "username": "testuser",
  "email": "test@example.com",
  "phone": "010-1234-5678",
  "createdAt": "2025-10-01T10:00:00",
  "updatedAt": "2025-10-01T10:00:00"
}
```

## 로컬 실행 방법

### 0. 환경변수 설정 (Docker Compose 사용 시 필수)
```bash
# .env.example을 복사하여 .env 생성
cp .env.example .env

# .env 파일을 편집하여 실제 값 입력
# 주의: DB_USERNAME과 MYSQL_USER는 동일해야 함
# 주의: DB_PASSWORD와 MYSQL_PASSWORD는 동일해야 함
```

### 빠른 시작 (권장)
```bash
# 스크립트 실행 권한 부여 (최초 1회)
chmod +x start.sh stop.sh

# 서비스 시작
./start.sh

# 서비스 중지
./stop.sh

# 데이터까지 삭제하며 중지
./stop.sh -v
```

### 1. Gradle로 실행 (개발 환경)
```bash
# H2 인메모리 DB 사용
./gradlew bootRun --args='--spring.profiles.active=dev'

# H2 콘솔 접속: http://localhost:8080/h2-console
# JDBC URL: jdbc:h2:mem:testdb
```

### 2. Docker Compose로 실행 (운영 환경)
```bash
# 환경변수 설정 (최초 1회)
cp .env.example .env
# .env 파일을 편집하여 DB 비밀번호 등 설정

# 전체 서비스 시작 (MySQL + Spring Boot)
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 서비스 중지
docker-compose down

# 볼륨까지 삭제
docker-compose down -v
```

### 3. Docker 단독 실행
```bash
# 이미지 빌드
docker build -t back-app .

# 컨테이너 실행
docker run -p 8080:8080 \
  -e SPRING_PROFILE=dev \
  back-app
```

## 환경 설정

### 개발 환경 (dev)
- H2 인메모리 데이터베이스
- DDL Auto: create-drop
- 상세한 로깅
- H2 콘솔 활성화

### 운영 환경 (prod)
- MySQL 8.0
- DDL Auto: validate
- 최소 로깅
- 커넥션 풀 최적화

### 환경변수
운영 환경에서 다음 환경변수를 설정할 수 있습니다:
```bash
SPRING_PROFILE=prod
DB_HOST=mysql
DB_PORT=3306
DB_NAME=backdb
DB_USERNAME=backuser
DB_PASSWORD=backpassword
SERVER_PORT=8080
```

## 테스트

### API 테스트 (curl)
```bash
# 헬스 체크
curl http://localhost:8080/api/users/health

# 사용자 생성
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","phone":"010-1234-5678"}'

# 모든 사용자 조회
curl http://localhost:8080/api/users

# 특정 사용자 조회
curl http://localhost:8080/api/users/1
```

## 주요 기능

### 1. 계층형 아키텍처
- Controller - Service - Repository 구조
- DTO를 통한 계층 간 데이터 전달
- Entity 직접 노출 방지

### 2. 예외 처리
- 전역 예외 핸들러 (`@RestControllerAdvice`)
- 일관된 에러 응답 형식
- Validation 오류 처리

### 3. 트랜잭션 관리
- `@Transactional` 선언적 트랜잭션
- 읽기 전용 트랜잭션 최적화
- 더티 체킹을 통한 업데이트

### 4. Docker 최적화
- Multi-stage build
- 레이어 캐싱
- 비root 사용자
- 헬스체크

## 향후 계획
- 테라폼으로 AWS 자원 생성
- AWS EC2 인스턴스에 자동으로 도커, nginx, redis, mysql 설치
- 도메인 구매 및 DNS 설정 (A, CNAME 레코드)
- CI/CD 파이프라인 구축
- 무중단 배포 구현

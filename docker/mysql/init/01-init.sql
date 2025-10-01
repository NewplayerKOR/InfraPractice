-- MySQL 초기화 스크립트
-- 이 파일은 MySQL 컨테이너 최초 실행 시 자동으로 실행됩니다

-- 데이터베이스가 없으면 생성 (docker-compose에서 이미 생성하므로 선택사항)
-- CREATE DATABASE IF NOT EXISTS backdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 사용자 테이블 생성 (ddl-auto가 validate일 경우 수동 생성 필요)
USE backdb;

CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 테스트 데이터 삽입 (선택사항)
INSERT INTO users (username, email, phone) VALUES
    ('admin', 'admin@example.com', '010-1234-5678'),
    ('testuser', 'test@example.com', '010-9876-5432')
ON DUPLICATE KEY UPDATE username=username;

-- 스크립트 설명:
-- - 운영 환경에서 ddl-auto: validate 사용 시 필요
-- - 테이블 인덱스 추가로 조회 성능 향상
-- - 테스트 데이터는 개발/테스트 환경에서만 사용

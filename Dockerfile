# Multi-stage build를 사용한 최적화된 Dockerfile

# Stage 1: Build
FROM gradle:8.14.3-jdk21 AS builder

# 작업 디렉토리 설정
WORKDIR /app

# Gradle 래퍼와 설정 파일 복사 (의존성 캐싱 최적화)
COPY gradle gradle
COPY gradlew .
COPY settings.gradle .
COPY build.gradle .

# 의존성 다운로드 (레이어 캐싱 활용)
RUN ./gradlew dependencies --no-daemon

# 소스 코드 복사
COPY src src

# 애플리케이션 빌드 (테스트 제외로 빌드 시간 단축)
RUN ./gradlew bootJar -x test --no-daemon

# Stage 2: Runtime
FROM eclipse-temurin:21-jre-alpine

# 보안을 위한 비root 사용자 생성
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# 작업 디렉토리 설정
WORKDIR /app

# 빌드 결과물만 복사 (이미지 크기 최소화)
COPY --from=builder /app/build/libs/*.jar app.jar

# 애플리케이션 포트
EXPOSE 8080

# 환경변수 설정
ENV SPRING_PROFILE=prod
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"

# 헬스체크 설정
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/api/users/health || exit 1

# 애플리케이션 실행
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dspring.profiles.active=$SPRING_PROFILE -jar app.jar"]

# Dockerfile 설명:
# 1. Multi-stage build로 최종 이미지 크기 최소화
# 2. Gradle 의존성 캐싱으로 빌드 속도 향상
# 3. Alpine Linux 기반 JRE로 경량화
# 4. 비root 사용자 사용으로 보안 강화
# 5. 헬스체크 설정으로 컨테이너 상태 모니터링
# 6. 환경변수로 프로파일 및 JVM 옵션 제어

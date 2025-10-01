# Terraform으로 AWS 인프라 구축

## 📋 생성되는 리소스

- ✅ EC2 인스턴스 (Ubuntu 22.04, t2.micro)
- ✅ 보안 그룹 (SSH, HTTP, HTTPS, 8080)
- ✅ Elastic IP (고정 IP)
- ✅ 자동 설치: Docker, Docker Compose, Git 등

## 🚀 사용 방법

### 1단계: AWS 키페어 생성

**PowerShell에서:**
```powershell
aws ec2 create-key-pair --key-name back-app-key --query 'KeyMaterial' --output text > back-app-key.pem
```

**권한 설정 (Windows):**
```powershell
icacls back-app-key.pem /inheritance:r
icacls back-app-key.pem /grant:r "%USERNAME%:R"
```

### 2단계: 설정 파일 준비

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
```

**수정 필수 항목:**
- key_name
- mysql_root_password
- mysql_password

### 3단계: Terraform 실행

```bash
# 초기화
terraform init

# 계획 확인
terraform plan

# 실행
terraform apply
```

### 4단계: 접속

```bash
# 출력된 명령어로 SSH 접속
ssh -i back-app-key.pem ubuntu@<EC2_IP>

# 초기화 로그 확인
cat /var/log/user_data.log
```

## 🛠️ 유용한 명령어

```bash
# 출력값 확인
terraform output

# 리소스 삭제
terraform destroy
```

## 💰 비용

- t2.micro: 프리티어 무료 (월 750시간)
- 사용하지 않을 때는 인스턴스 중지 권장

## 다음 단계

인프라 구축 완료 후 GitHub Actions로 자동 배포를 진행합니다.

# Terraform 실행 가이드 (Windows)

## 📌 시작하기 전에

현재 상태 확인:
- ✅ AWS 계정 있음
- ✅ IAM Access Key 있음
- ✅ AWS CLI 설치됨
- ✅ Terraform 설치됨
- ✅ Windows 환경

## 🚀 단계별 실행

### STEP 1: AWS CLI 설정 확인

```powershell
# AWS CLI 설정 확인
aws configure list

# 출력 예시:
#       Name                    Value             Type    Location
#       ----                    -----             ----    --------
#    profile                <not set>             None    None
# access_key     ****************ABCD shared-credentials-file
# secret_key     ****************WXYZ shared-credentials-file
#     region           ap-northeast-2      config-file    ~/.aws/config
```

**설정이 안 되어 있다면:**
```powershell
aws configure
# AWS Access Key ID: 입력
# AWS Secret Access Key: 입력
# Default region name: ap-northeast-2
# Default output format: json
```

### STEP 2: AWS 키페어 생성 (SSH 접속용)

```powershell
# PowerShell에서 실행
cd terraform

# 키페어 생성
aws ec2 create-key-pair `
  --key-name back-app-key `
  --region ap-northeast-2 `
  --query 'KeyMaterial' `
  --output text | Out-File -Encoding ascii -FilePath back-app-key.pem

# 권한 설정 (중요!)
icacls back-app-key.pem /inheritance:r
icacls back-app-key.pem /grant:r "$env:USERNAME`:R"
```

**또는 AWS 콘솔에서 생성:**
1. AWS 콘솔 로그인
2. EC2 → 네트워크 및 보안 → 키 페어
3. "키 페어 생성" 클릭
4. 이름: `back-app-key`
5. 파일 형식: `.pem`
6. 다운로드 후 `terraform/` 폴더에 저장

### STEP 3: 본인 공인 IP 확인 (보안 강화)

```powershell
# PowerShell에서
(Invoke-WebRequest -Uri "https://api.ipify.org").Content
```

IP 주소를 메모해두세요. (예: 123.456.789.012)

### STEP 4: terraform.tfvars 파일 생성

```powershell
# terraform 디렉토리에서
cd terraform
cp terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
```

**terraform.tfvars 파일 내용 (수정 필요):**
```hcl
# AWS 설정
aws_region  = "ap-northeast-2"
aws_profile = "default"

# 환경 설정
environment = "dev"

# EC2 설정
instance_type = "t2.micro"
instance_name = "back-app-server"
key_name      = "back-app-key"    # ✅ 키페어 이름

# 네트워크 설정 (보안 강화)
allowed_ssh_cidr = ["123.456.789.012/32"]  # ✅ 본인 IP로 변경!
# 또는 모든 IP 허용 (비권장)
# allowed_ssh_cidr = ["0.0.0.0/0"]

# 애플리케이션 설정
app_port = 8080

# 데이터베이스 비밀번호
mysql_root_password = "MyStrong!RootPass123"   # ✅ 강력한 비밀번호로 변경!
mysql_password      = "MyStrong!UserPass456"   # ✅ 강력한 비밀번호로 변경!
```

### STEP 5: Terraform 초기화

```powershell
# terraform 디렉토리에서
terraform init
```

**성공 메시지 예시:**
```
Terraform has been successfully initialized!
```

### STEP 6: 실행 계획 확인

```powershell
terraform plan
```

**확인 사항:**
- ✅ EC2 인스턴스 1개 생성
- ✅ 보안 그룹 1개 생성
- ✅ Elastic IP 1개 생성
- ✅ 총 3개의 리소스

### STEP 7: 인프라 생성

```powershell
terraform apply
```

**확인 메시지:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

**`yes` 입력 후 Enter**

**예상 소요 시간:** 3-5분

### STEP 8: 결과 확인

```powershell
# 모든 출력값 확인
terraform output

# 특정 출력값만 확인
terraform output instance_public_ip
terraform output ssh_connection_command
```

**출력 예시:**
```
instance_public_ip = "52.79.123.456"
ssh_connection_command = "ssh -i back-app-key.pem ubuntu@52.79.123.456"
application_url = "http://52.79.123.456:8080/api/users/health"
```

### STEP 9: EC2 접속 확인

```powershell
# SSH 접속
ssh -i back-app-key.pem ubuntu@<EC2_PUBLIC_IP>

# 예시
# ssh -i back-app-key.pem ubuntu@52.79.123.456
```

**접속 후 확인:**
```bash
# Docker 설치 확인
docker --version
docker compose version

# 초기화 로그 확인
cat /var/log/user_data.log

# 초기화 완료 확인
ls /home/ubuntu/initialization_complete
```

**초기화가 완료되면 (3-5분 소요):**
- Docker 설치됨
- Docker Compose 설치됨
- 스왑 메모리 2GB 생성됨
- 애플리케이션 디렉토리 생성됨

## ✅ 성공 확인 체크리스트

- [ ] terraform apply 성공
- [ ] EC2 인스턴스 생성 확인 (AWS 콘솔)
- [ ] Elastic IP 할당 확인
- [ ] SSH 접속 성공
- [ ] Docker 설치 확인 (`docker --version`)
- [ ] 초기화 완료 확인 (`cat /var/log/user_data.log`)

## 🔧 문제 해결

### 1. "InvalidKeyPair.NotFound" 오류
```
Error: InvalidKeyPair.NotFound: The key pair 'back-app-key' does not not exist
```

**해결:**
- AWS 콘솔에서 키페어가 생성되었는지 확인
- 리전이 `ap-northeast-2` (서울)인지 확인
- terraform.tfvars의 key_name이 정확한지 확인

### 2. "UnauthorizedOperation" 오류
```
Error: UnauthorizedOperation: You are not authorized to perform this operation
```

**해결:**
- IAM 사용자에게 EC2 권한 부여 필요
- AWS 콘솔 → IAM → 사용자 → 권한 추가
- 정책: `AmazonEC2FullAccess` 연결

### 3. SSH 접속 안 됨
```
Connection timed out
```

**해결 방법:**
- 보안 그룹에서 SSH(22) 포트 열려있는지 확인
- `allowed_ssh_cidr`에 본인 IP가 포함되어 있는지 확인
- 인스턴스 상태가 "running"인지 확인
- 키페어 파일 권한 확인

### 4. 초기화 스크립트 확인
```bash
# EC2 접속 후
cat /var/log/user_data.log

# 실시간 로그 확인
tail -f /var/log/cloud-init-output.log
```

### 5. Docker 설치 안 됨
```bash
# EC2 접속 후 수동 실행
sudo bash /var/lib/cloud/instance/user-data.txt
```

## 🛑 인프라 삭제

**⚠️ 주의: 모든 리소스가 삭제됩니다!**

```powershell
# terraform 디렉토리에서
terraform destroy

# 확인 메시지에 'yes' 입력
```

## 📊 비용 확인

```powershell
# AWS CLI로 현재 실행 중인 인스턴스 확인
aws ec2 describe-instances `
  --region ap-northeast-2 `
  --filters "Name=instance-state-name,Values=running" `
  --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,PublicIpAddress]' `
  --output table
```

**프리티어 범위:**
- t2.micro: 월 750시간 무료
- EBS 30GB까지 무료
- Elastic IP (인스턴스 연결 시) 무료

## 🎯 다음 단계

인프라 구축 완료! 🎉

이제 **GitHub Actions**로 애플리케이션 자동 배포를 설정하겠습니다.

다음 파일을 확인하세요:
- `GITHUB_ACTIONS_GUIDE.md` (다음에 생성 예정)

## 💡 유용한 명령어 모음

```powershell
# 인스턴스 상태 확인
aws ec2 describe-instances --region ap-northeast-2 --instance-ids <INSTANCE_ID>

# 인스턴스 중지 (비용 절약)
aws ec2 stop-instances --region ap-northeast-2 --instance-ids <INSTANCE_ID>

# 인스턴스 시작
aws ec2 start-instances --region ap-northeast-2 --instance-ids <INSTANCE_ID>

# Terraform 상태 확인
terraform show

# 특정 출력값 확인
terraform output instance_id
```

## 📞 추가 도움이 필요하면

- [Terraform AWS Provider 문서](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 문서](https://docs.aws.amazon.com/ec2/)
- [AWS 프리티어](https://aws.amazon.com/ko/free/)

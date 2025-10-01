# Terraform 및 Provider 설정
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider 설정
provider "aws" {
  region = var.aws_region
  
  # AWS CLI 설정을 자동으로 사용
  # ~/.aws/credentials 파일의 프로파일 사용
  profile = var.aws_profile
  
  default_tags {
    tags = {
      Project     = "InfraPractice"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# 설명:
# - AWS CLI로 설정한 자격증명 자동 사용
# - 모든 리소스에 기본 태그 자동 적용
# - 서울 리전(ap-northeast-2) 사용

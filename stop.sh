#!/bin/bash

# 서비스 중지 스크립트
# 사용법: ./stop.sh [옵션]
# 옵션: -v (볼륨까지 삭제)

set -e

echo "================================"
echo "Back Application 중지 스크립트"
echo "================================"
echo ""

if [ "$1" == "-v" ]; then
    echo "⚠️  볼륨까지 삭제합니다. 모든 데이터가 삭제됩니다!"
    read -p "계속하시겠습니까? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  서비스 중지 및 볼륨 삭제 중..."
        docker-compose down -v
        echo "✅ 서비스가 중지되고 모든 데이터가 삭제되었습니다."
    else
        echo "취소되었습니다."
        exit 0
    fi
else
    echo "🛑 서비스 중지 중..."
    docker-compose down
    echo "✅ 서비스가 중지되었습니다."
    echo "💡 데이터는 유지됩니다. 데이터까지 삭제하려면 './stop.sh -v'를 사용하세요."
fi

echo ""

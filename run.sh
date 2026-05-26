#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Имя образа
IMAGE_NAME="riscv-xv6-env"

echo -e "${YELLOW}🔨 Building Docker image...${NC}"
docker build -t $IMAGE_NAME .

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}❌ Build failed. Exiting.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful.${NC}"
echo -e "${YELLOW}🚀 Starting container...${NC}"

# Запуск контейнера с монтированием текущей директории
docker run -it --rm \
    -v $(pwd):/workspace \
    $IMAGE_NAME

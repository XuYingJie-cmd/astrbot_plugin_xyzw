#!/bin/bash
set -x

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# 1. 清理所有非 Ubuntu 源
log "清理混杂源"
rm -f /etc/apt/sources.list.d/*.list

# 2. 配置清华源
log "配置APT镜像源"
tee /etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu jammy-security main restricted universe multiverse
EOF

# 3. 清理缓存并更新
log "更新系统"
apt-get clean
rm -rf /var/lib/apt/lists/*
apt-get update -o Acquire::AllowInsecureRepositories=true

# 4. 安装依赖（绕过签名验证）
log "安装系统依赖"
apt-get install -y --allow-unauthenticated \
    libgl1-mesa-glx \
    libglib2.0-0

# 5. 安装 Python 依赖（使用阿里云镜像）
log "安装Python依赖"
pip install -r requirements.txt \
    -i https://mirrors.aliyun.com/pypi/simple \
    --trusted-host mirrors.aliyun.com

set +x
log "完成！"
#!/bin/bash

# 开启调试模式
set -x

# 日志函数
log() {
    local message="$1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $message"
}

# 配置正确的 Ubuntu 22.04 (jammy) 源
log "配置软件源"
tee /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu jammy-security main restricted universe multiverse
EOF

# 更新软件源（忽略可能的 GPG 警告，通常不影响依赖安装）
log "更新软件源"
apt-get update -o Acquire::AllowInsecureRepositories=true

# 安装依赖
log "安装系统依赖"
apt-get install -y --allow-unauthenticated libgl1-mesa-glx libglib2.0-0

# 安装 Python 包
log "安装 Python 依赖"
pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple

# 关闭调试模式
set +x
log "完成！"
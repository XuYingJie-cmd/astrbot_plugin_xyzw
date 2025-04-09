#!/bin/bash
set -x

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# 1. 配置清华APT源
log "配置APT镜像源"
tee /etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
EOF

# 2. 更新并安装依赖
log "更新系统"
apt-get update -o Acquire::AllowInsecureRepositories=true
apt-get install -y --no-install-recommends libgl1-mesa-glx libglib2.0-0

# 3. 安装Python包（多镜像源）
log "安装Python依赖"
pip install -r requirements.txt \
  -i https://pypi.tuna.tsinghua.edu.cn/simple \
  --extra-index-url https://mirrors.aliyun.com/pypi/simple \
  --trusted-host mirrors.aliyun.com pypi.tuna.tsinghua.edu.cn

set +x
log "完成！"
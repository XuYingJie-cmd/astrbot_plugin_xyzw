#!/bin/bash
set -euxo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# 1. 配置APT源（根据实际系统选择）
log "配置APT镜像源"
tee /etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
EOF

# 2. 修复GPG密钥
log "修复GPG公钥"
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C

# 3. 更新系统
log "更新系统"
apt-get update -y && apt-get upgrade -y
apt-get install -y --no-install-recommends libgl1-mesa-glx libglib2.0-0

# 4. 安装Python依赖（多源加速）
log "安装Python依赖"
pip install --use-feature=fast-deps --no-cache-dir -r requirements.txt \
  -i https://pypi.tuna.tsinghua.edu.cn/simple \
  --extra-index-url https://mirrors.aliyun.com/pypi/simple \
  --extra-index-url https://pypi.mirrors.ustc.edu.cn/simple

set +x
log "完成！"
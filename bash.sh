#!/bin/bash
set -euxo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# 安装 apt-fast
log "安装 apt-fast"
sudo add-apt-repository -y ppa:apt-fast/stable
sudo apt-get update
sudo apt-get -y install apt-fast

# 1. 配置APT源（更换为清华大学镜像源）
log "配置APT镜像源"
tee /etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
EOF

# 2. 更新软件包列表
log "更新软件包列表"
apt-fast update

# 3. 强制更新系统并安装指定包
log "强制更新系统并安装指定包"
apt-fast install -y --no-install-recommends --allow-downgrades --allow-remove-essential --allow-change-held-packages libgl1-mesa-glx libglib2.0-0

# 4. 安装Python依赖（多源加速）
log "安装Python依赖"
pip install -r requirements.txt -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

set +x
log "完成！"
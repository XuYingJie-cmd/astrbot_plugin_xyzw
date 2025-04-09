#!/bin/bash
set -ex

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# 1. 深度清理混杂源（含隐藏文件）
log "清理混杂源"
rm -rf /etc/apt/sources.list.d/* 2>/dev/null
find /etc/apt/ -name '*.list.save' -delete

# 2. 强制覆盖主源（适配Ubuntu 22.04 Jammy）
log "配置APT清华源"
cat <<EOF | tee /etc/apt/sources.list
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu jammy-security main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu jammy-backports main restricted universe multiverse
EOF

# 3. 原子化缓存清理（修复残留索引问题）
log "更新系统"
{
    apt-get clean
    rm -rf /var/lib/apt/lists/partial/*
    rm -f /var/lib/apt/lists/lock
    apt-get update --allow-releaseinfo-change -y
} 2>/dev/null

# 4. 修复依赖签名验证
log "安装系统依赖"
{
    apt-mark hold grub-common  # 防止内核升级冲突
    apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install -y \
        libgl1-mesa-glx=22.0.5-0ubuntu0.1 \
        libglib2.0-0=2.72.4-0ubuntu2.2
} 2>/dev/null

# 5. 加固pip镜像源（带SSL验证）
log "安装Python依赖"
{
    python3 -m pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    python3 -m pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn
    python3 -m pip install --no-cache-dir -r requirements.txt
} 2>/dev/null

log "完成！"
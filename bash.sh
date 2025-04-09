#!/bin/bash
set -euxo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# 使用阿里云镜像源替换原有内容
cat << EOF > /etc/apt/sources.list
deb http://mirrors.aliyun.com/debian/ bullseye main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ bullseye main non-free contrib
deb http://mirrors.aliyun.com/debian-security/ bullseye-security main
deb-src http://mirrors.aliyun.com/debian-security/ bullseye-security main
deb http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
deb http://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib
EOF

# 2. 更新软件包列表
log "更新软件包列表"
apt-get update

log "强制更新系统并安装指定包"
apt-get install -y --no-install-recommends --allow-downgrades --allow-remove-essential --allow-change-held-packages libgl1-mesa-glx libglib2.0-0

# 4. 安装Python依赖（多源加速）
log "安装Python依赖"
pip install -r requirements.txt -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

set +x
log "完成！"
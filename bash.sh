#!/bin/bash
set -x

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# 2. 配置 APT 源，这里提供了多个镜像源供选择，你可以根据实际情况修改
MIRROR="http://mirrors.aliyun.com/ubuntu/"
# MIRROR="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
# MIRROR="https://mirrors.ustc.edu.cn/ubuntu/"

log "配置 APT 镜像源"
tee /etc/apt/sources.list <<EOF
deb $MIRROR jammy main restricted universe multiverse
deb $MIRROR jammy-updates main restricted universe multiverse
deb $MIRROR jammy-security main restricted universe multiverse
EOF

# 3. 更新并安装依赖
log "更新并安装指定依赖"
# 最多重试 3 次
MAX_ATTEMPTS=3
for ((attempt = 1; attempt <= MAX_ATTEMPTS; attempt++)); do
    if apt-get install -y --no-install-recommends --only-upgrade libgl1-mesa-glx libglib2.0-0; then
        log "依赖安装成功"
        break
    elif [ $attempt -eq $MAX_ATTEMPTS ]; then
        log "依赖安装失败，已达到最大重试次数"
        exit 1
    else
        log "依赖安装失败，正在进行第 $((attempt + 1)) 次尝试..."
    fi
done

# 4. 安装 Python 包（多镜像源）
log "安装 Python 依赖"
pip install -r requirements.txt \
  -i https://pypi.tuna.tsinghua.edu.cn/simple \
  --extra-index-url https://mirrors.aliyun.com/pypi/simple \
  --trusted-host mirrors.aliyun.com pypi.tuna.tsinghua.edu.cn \
  --no-cache-dir

set +x
log "完成！"
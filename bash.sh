#!/bin/bash
set -x

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# 1. 备份并移除原来的 APT 源
log "备份并移除原来的 APT 源"
if [ -f /etc/apt/sources.list ]; then
    mv /etc/apt/sources.list /etc/apt/sources.list.bak
fi
> /etc/apt/sources.list

# 备份并清空 /etc/apt/sources.list.d/ 目录下的所有文件
if [ -d /etc/apt/sources.list.d ]; then
    for file in /etc/apt/sources.list.d/*.list; do
        if [ -f "$file" ]; then
            mv "$file" "$file.bak"
            > "$file"
        fi
    done
fi

# 2. 配置阿里云 APT 源
log "配置 APT 镜像源"
tee /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
EOF

# 3. 更新并安装依赖
log "更新系统"
apt-get update -o Acquire::AllowInsecureRepositories=true
apt-get install -y --no-install-recommends libgl1-mesa-glx libglib2.0-0

# 4. 安装 Python 包（多镜像源）
log "安装 Python 依赖"
pip install -r requirements.txt \
  -i https://pypi.tuna.tsinghua.edu.cn/simple \
  --extra-index-url https://mirrors.aliyun.com/pypi/simple \
  --trusted-host mirrors.aliyun.com pypi.tuna.tsinghua.edu.cn

# 5. 恢复原来的 APT 源
log "恢复原来的 APT 源"
if [ -f /etc/apt/sources.list.bak ]; then
    mv /etc/apt/sources.list.bak /etc/apt/sources.list
fi

# 恢复 /etc/apt/sources.list.d/ 目录下的备份文件
if [ -d /etc/apt/sources.list.d ]; then
    for file in /etc/apt/sources.list.d/*.list.bak; do
        if [ -f "$file" ]; then
            mv "$file" "${file%.bak}"
        fi
    done
fi

set +x
log "完成！"
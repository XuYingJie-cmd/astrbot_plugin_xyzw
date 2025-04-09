#!/bin/bash

# 开启调试模式，方便调试时查看命令执行情况
set -x

# 定义日志函数，用于记录脚本执行过程中的信息
log() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $message"
}

# 获取当前脚本所在目录
log "正在执行: 获取当前脚本所在目录"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ $? -ne 0 ]; then
    log "获取脚本所在目录失败"
    exit 1
fi

# 切换到包含 requirements.txt 的目录
log "正在执行: 切换到包含 requirements.txt 的目录"
cd "$SCRIPT_DIR"
if [ $? -ne 0 ]; then
    log "切换到 $SCRIPT_DIR 目录失败"
    exit 1
fi

# 安装 Python 包
log "正在执行: 安装 Python 包"
pip install -r requirements.txt -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
if [ $? -ne 0 ]; then
    log "安装 Python 包失败"
    exit 1
fi



# 更新软件包列表
log "正在执行: 更新软件包列表"
apt-get update
if [ $? -ne 0 ]; then
    log "更新软件包列表失败，尝试恢复源文件"
    cp /etc/apt/sources.list.bak /etc/apt/sources.list
    exit 1
fi

# 安装依赖
log "正在执行: 安装依赖"
apt-get install -y libgl1-mesa-glx
if [ $? -ne 0 ]; then
    log "安装 libgl1-mesa-glx 失败"
    exit 1
fi

apt-get install -y libglib2.0-0
if [ $? -ne 0 ]; then
    log "安装 libglib2.0-0 失败"
    exit 1
fi

# 关闭调试模式
set +x
log "脚本执行成功"
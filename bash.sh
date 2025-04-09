#!/bin/bash

# 开启调试模式，方便调试时查看命令执行情况
set -x

# 定义颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 定义日志函数，用于记录脚本执行过程中的信息
log() {
    local message="$1"
    local color="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${color}[$timestamp] $message${NC}"
}

# 安装 Python 包
log "正在执行: 安装 Python 包" "$YELLOW"
pip install -r requirements.txt -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
if [ $? -ne 0 ]; then
    log "安装 Python 包失败" "$RED"
    exit 1
else
    log "Python 包安装成功" "$GREEN"
fi

# 更新软件包列表
log "正在执行: 更新软件包列表" "$YELLOW"
apt-get update
if [ $? -ne 0 ]; then
    log "更新软件包列表失败，尝试恢复源文件" "$RED"
    cp /etc/apt/sources.list.bak /etc/apt/sources.list
    exit 1
else
    log "软件包列表更新成功" "$GREEN"
fi

# 安装依赖
log "正在执行: 安装 libgl1-mesa-glx" "$YELLOW"
apt-get install -y libgl1-mesa-glx
if [ $? -ne 0 ]; then
    log "安装 libgl1-mesa-glx 失败" "$RED"
    exit 1
else
    log "libgl1-mesa-glx 安装成功" "$GREEN"
fi

log "正在执行: 安装 libglib2.0-0" "$YELLOW"
apt-get install -y libglib2.0-0
if [ $? -ne 0 ]; then
    log "安装 libglib2.0-0 失败" "$RED"
    exit 1
else
    log "libglib2.0-0 安装成功" "$GREEN"
fi

# 关闭调试模式
set +x
log "脚本执行成功" "$GREEN"
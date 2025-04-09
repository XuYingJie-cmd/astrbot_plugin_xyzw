#!/bin/bash

# 开启调试模式，方便调试时查看命令执行情况
set -x

# 定义日志函数，用于记录脚本执行过程中的信息
log() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $message"
}



# 检查并创建 sources.list 文件
if [ ! -f /etc/apt/sources.list ]; then
    log "创建 /etc/apt/sources.list 文件"
    # 这里假设使用 Ubuntu 20.04 (focal) 的源，根据实际情况修改
    echo "deb http://archive.ubuntu.com/ubuntu focal main restricted universe multiverse" |  tee /etc/apt/sources.list
fi

# 更新依赖包列表
log "正在执行: 更新依赖包列表"
apt-get update
if [ $? -ne 0 ]; then
    log "更新依赖包列表失败"
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

# 安装 Python 包
log "正在执行: 安装 Python 包"
pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple
if [ $? -ne 0 ]; then
    log "安装 Python 包失败"
    exit 1
fi

# 关闭调试模式
set +x
log "脚本执行成功"
#!/bin/bash

# 开启调试模式，方便调试时查看命令执行情况
set -x

# 定义日志函数，用于记录脚本执行过程中的信息
log() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $message"
}

# 导入 Ubuntu 官方 GPG 公钥（解决签名验证问题）
log "正在导入 Ubuntu 官方 GPG 公钥"
apt-get update && apt-get install -y gnupg
if [ $? -ne 0 ]; then
    log "安装 gnupg 失败"
    exit 1
fi
gpg --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C
if [ $? -ne 0 ]; then
    log "导入 GPG 公钥失败"
    exit 1
fi
gpg --export --armor 871920D1991BC93C > /etc/apt/trusted.gpg.d/ubuntu-jammy.gpg

# 替换为阿里云镜像源
log "正在执行: 替换软件源为阿里云镜像源"
> /etc/apt/sources.list  # 先清空原文件
echo "deb http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list

# 安装 Python 包
log "正在执行: 安装 Python 包"
pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple
if [ $? -ne 0 ]; then
    log "安装 Python 包失败"
    exit 1
fi

# 更新软件包列表
log "正在执行: 更新软件包列表"
apt-get update
if [ $? -ne 0 ]; then
    log "更新软件包列表失败"
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
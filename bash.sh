#!/bin/bash

# 获取当前脚本所在目录
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 切换到包含 requirements.txt 的目录
cd "$SCRIPT_DIR"

# 安装 Python 包
pip install -r requirements.txt -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
if [ $? -ne 0 ]; then
    echo "安装 Python 包失败"
    exit 1
fi

# 备份原有的软件源文件
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 替换软件源为阿里云镜像源
sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/mirrors.aliyun.com\/ubuntu\//g' /etc/apt/sources.list
sed -i 's/http:\/\/security.ubuntu.com\/ubuntu\//http:\/\/mirrors.aliyun.com\/ubuntu\//g' /etc/apt/sources.list

# 更新软件包列表
apt-get update
if [ $? -ne 0 ]; then
    echo "更新软件包列表失败"
    exit 1
fi

# 安装依赖
apt-get install -y libgl1-mesa-glx
if [ $? -ne 0 ]; then
    echo "安装 libgl1-mesa-glx 失败"
    exit 1
fi
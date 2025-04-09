#!/bin/bash

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

# 安装 Python 包
pip install -r requirements.txt -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
if [ $? -ne 0 ]; then
    echo "安装 Python 包失败"
    exit 1
fi
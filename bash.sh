#!/bin/bash

# 备份原有的软件源列表
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 替换为阿里云软件源
cat << EOF > /etc/apt/sources.list
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs) main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs) main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-updates main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-security main restricted universe multiverse
EOF

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
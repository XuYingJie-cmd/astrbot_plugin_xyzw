#!/bin/bash

# 备份 sources.list 文件（如果存在）
if [ -f "/etc/apt/sources.list" ]; then
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    if [ $? -ne 0 ]; then
        echo "备份 sources.list 文件失败"
        exit 1
    fi
fi

# 创建新的 sources.list 文件并写入清华镜像源内容
cat << EOF > /etc/apt/sources.list
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
EOF
if [ $? -ne 0 ]; then
    echo "写入新的 sources.list 文件失败"
    exit 1
fi

# 导入缺失的公钥
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C
if [ $? -ne 0 ]; then
    echo "导入公钥失败"
    exit 1
fi

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
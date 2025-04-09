#!/bin/bash

# 1. 配置 APT 镜像源和参数
sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
echo 'Acquire::http::Timeout "5";' |  tee /etc/apt/apt.conf.d/99timeout
echo 'Acquire::Retries "3";' |  tee -a /etc/apt/apt.conf.d/99timeout

# 2. 更新软件包列表（使用 apt-fast 加速）
apt-fast update || { echo "更新软件包列表失败"; exit 1; }

# 3. 安装依赖
apt-fast install -y libgl1-mesa-glx || { echo "安装 libgl1-mesa-glx 失败"; exit 1; }

# 4. 配置 PIP 镜像源
mkdir -p ~/.pip
echo -e "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple" > ~/.pip/pip.conf

# 5. 安装 Python 包
pip install -r requirements.txt || { echo "安装 Python 包失败"; exit 1; }
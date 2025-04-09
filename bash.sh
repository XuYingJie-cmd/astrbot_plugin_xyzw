#!/bin/bash

# 检查 aptitude 是否安装，如果未安装则进行安装
if ! command -v aptitude &> /dev/null
then
    apt-get install -y aptitude
fi

# 安装依赖并显示进度条
echo "正在安装 libgl1-mesa-glx..."
aptitude -y install libgl1-mesa-glx | while read -r line; do
    # 简单模拟进度条，根据 aptitude 的输出更新进度
    if [[ $line == *"%"* ]]; then
        progress=$(echo "$line" | grep -o '[0-9]\+%' | tr -d '%')
        printf "\r安装进度: %3d%%" "$progress"
    fi
done
echo

# 检查安装是否成功
if [ $? -ne 0 ]; then
    echo "安装 libgl1-mesa-glx 失败"
    exit 1
fi

# 安装 tqdm 以支持 pip 进度条
pip install tqdm

# 安装 Python 包并显示进度条
echo "正在安装 Python 包..."
pip install -r requirements.txt --progress-bar=on | while read -r line; do
    if [[ $line == *"%"* ]]; then
        progress=$(echo "$line" | grep -o '[0-9]\+%' | tr -d '%')
        printf "\r安装进度: %3d%%" "$progress"
    fi
done
echo

# 检查安装是否成功
if [ $? -ne 0 ]; then
    echo "安装 Python 包失败"
    exit 1
fi
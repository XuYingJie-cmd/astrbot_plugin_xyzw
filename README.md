# xyzw_ocr

咸鱼之王小游戏 插件模板

关于咸鱼之王算宝箱,金鱼,罐子的一个插件 接入了飞浆ocr 请考虑服务器的资源是否足够 建议4G以上

# 注 该插件依赖飞浆ocr 需要 进入容器中安装相对应的依赖
步骤如:

    docker exec -it astrbot /bin/bash
    cd data/plugins/astrbot_plugin_xyzw
    bash bash.sh



#   如果补充完毕仍有报错请根据报错补充相对依赖的包

    目前仅测试gewe为正常的
    
    win只需要pip install -r requirements.txt即可 然后根据报错补充依赖?
    
    欢迎大佬提交PR修改(主要是这个依赖库下载太慢了)

# 建议  如果 服务器例如2H2G那种的 容易卡死  请给docker设置上例如

    docker update --cpus=1 --memory=900m --memory-swap=1800m astrbot
    docker update --cpus=1 --memory=700m --memory-swap=1400m gewe

# 配置参数
    可以配置如日期 节日 要求金砖数量 宝箱数量等参数


# 支持

[帮助文档](https://github.com/XuYingJie-cmd/astrbot_plugin_xyzw)

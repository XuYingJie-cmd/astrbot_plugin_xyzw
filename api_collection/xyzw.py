from astrbot.api import event
from astrbot.api.all import *
import aiohttp
import logging
import re
from datetime import datetime
import math
from astrbot.api.event import filter, AstrMessageEvent, MessageEventResult
from astrbot.api.message_components import Video, Plain, Image
from ..config import GLOBAL_CONFIG
# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 固定参数
ITEM_NAMES = [
    "木质宝箱", "青铜宝箱", "黄金宝箱", "铂金宝箱",
    "黄金鱼竿", "金砖", "招募令", "宝箱积分"
]
# HUODONG = "端午节"
# DAY = "2025-5-30"
# JINZHUAN_GOAL = 230000
# ZHAOMULING_GOAL = 3000
# YUGAN_GOAL = 650
# BAOXIANG_GOAL = 28000


def extract_item_value(value_str: str) -> int:
    """
    提取整数数值（支持 "万" 单位）
    :param value_str: 数值字符串（如 "17.53万"）
    :return: 整数数值
    """
    if '万' in value_str:
        return int(float(value_str.replace('万', '')) * 10000)
    return int(value_str)


class Item:
    def __init__(self, item_name: str, value_str: str):
        self.item_name = item_name
        self.value = extract_item_value(value_str)


async def suanjinyu(text: str) -> MessageChain:
    logger.info(f"处理主线关卡识别结果: {text}")

    # 获取配置参数
    DAY = GLOBAL_CONFIG["date"]
    HUODONG = GLOBAL_CONFIG["jieri"]
    JINZHUAN_GOAL = GLOBAL_CONFIG["jinzhuan"]
    ZHAOMULING_GOAL = GLOBAL_CONFIG["zhaomuling"]
    YUGAN_GOAL = GLOBAL_CONFIG["yugan"]
    BAOXIANG_GOAL = GLOBAL_CONFIG["baoxiang"]

    result = MessageChain()
    # 正则匹配物品信息
    pattern = re.compile(
        r'(木质宝箱|青铜宝箱|黄金宝箱|铂金宝箱|黄金鱼竿|金砖|招募令|宝箱积分)'
        r'(?:\s*[×xX]\s*)'
        r'(\d+\.?\d*万?)',
        re.IGNORECASE
    )

    # 过滤有效物品
    items = [
        Item(match.group(1), match.group(2))
        for match in pattern.finditer(text)
        if match.group(1) in ITEM_NAMES
    ]

    # 初始化计数
    item_counts = {name: 0 for name in ITEM_NAMES}
    for item in items:
        item_counts[item.item_name] += item.value

    # 计算总积分
    total_score = (
            item_counts['木质宝箱'] * 1 +
            item_counts['青铜宝箱'] * 10 +
            item_counts['黄金宝箱'] * 20 +
            item_counts['铂金宝箱'] * 50 +
            item_counts['宝箱积分']
    )

    # 计算剩余天数
    current_date = datetime.now()
    event_day = datetime.strptime(DAY, "%Y-%m-%d")
    days_remaining = (event_day - current_date).days or 1  # 避免除以0

    # 预测数值
    predicted_jinzhuan = item_counts['金砖'] + days_remaining * 2700
    predicted_zhaomuling = item_counts['招募令'] + days_remaining * 4
    predicted_yugan = item_counts['黄金鱼竿'] + days_remaining * 1
    predicted_baoxiang = total_score + days_remaining * 150

    # 计算差距
    jinzhuan_diff = JINZHUAN_GOAL - item_counts['金砖']
    zhaomuling_diff = ZHAOMULING_GOAL - item_counts['招募令']
    yugan_diff = YUGAN_GOAL - item_counts['黄金鱼竿']
    baoxiang_diff = BAOXIANG_GOAL - total_score

    # 构建状态描述
    status = f"""
距离下次{HUODONG}结束还有{days_remaining}天
——————现有——————
金砖：{item_counts['金砖']}个
招募令：{item_counts['招募令']}个
黄金鱼竿：{item_counts['黄金鱼竿']}个
宝箱积分：{total_score}分
——————差距——————
金砖：{'缺少' if jinzhuan_diff > 0 else '溢出'}{abs(jinzhuan_diff)}个
招募令：{'缺少' if zhaomuling_diff > 0 else '溢出'}{abs(zhaomuling_diff)}个
黄金鱼竿：{'缺少' if yugan_diff > 0 else '溢出'}{abs(yugan_diff)}个
宝箱积分：{'缺少' if baoxiang_diff > 0 else '溢出'}{abs(baoxiang_diff)}分
———预测{days_remaining}天后———
金砖：{predicted_jinzhuan}个
招募令：{predicted_zhaomuling}个
黄金鱼竿：{predicted_yugan}个
宝箱积分：{predicted_baoxiang}分
仅为推荐数值，高图鉴保底资源
预测资源为自然增长
算一次一块钱
请麻烦找群主缴费
谢谢配合
"""
    print(status.strip())
    result.chain = [
        Plain(status.strip()),
    ]
    return result  # 使用strip()去除首尾空行

def get_number_from_word(word):
    return int(word.replace('X', ''))
async def baoxiang(text: str) -> MessageChain:
    print(f"处理积分值识别结果: {text}")
    result = MessageChain()
    # 取积分值
    parts = text.split("积分值")
    jifenzhi = 0
    if len(parts) > 1:
        pattern = re.compile(r"\d+(?=/)")
        match = pattern.search(parts[1])
        if match:
            jifenzhi = int(match.group())

    # 第一步：提取所有带 X 的数据
    x_pattern = re.compile(r"X\d+")
    x_data = x_pattern.findall(text)
    print("第一步：提取所有带X ", x_data)

    # xData 去掉第二个
    if len(x_data) > 1:
        del x_data[1]
    print("第一步：提取所有带X ", x_data)

    if len(x_data) >= 4:
        # 这里假设 xData 中存储的元素就是宝箱信息，我们根据顺序进行赋值
        muzhi = get_number_from_word(x_data[0])  # 木制
        qingtong = get_number_from_word(x_data[1])  # 青铜
        huangjin = get_number_from_word(x_data[2])  # 黄金
        bojin = get_number_from_word(x_data[3])  # 铂金

        muzhif = math.ceil(muzhi * 1)  # 木制
        qingtongf = math.ceil(qingtong * 10)  # 青铜
        huangjinf = math.ceil(huangjin * 20)  # 黄金
        bojinf = math.ceil(bojin * 50)  # 铂金

        # 合计积分
        heji = muzhif + qingtongf + huangjinf + bojinf + jifenzhi
        # 不开木制
        bukaimuzhi = round((qingtongf + huangjinf + bojinf) / 3440, 2)
        # 不开铂金
        bukaibojin = round((muzhif + qingtongf + huangjinf) / 3440, 2)
        # 宝箱周
        lun = round(heji / 3440, 2)
        # 奖后积分
        jianghou = math.ceil(heji * 2.4)

        print(
            f"木质宝箱个数: {muzhi}, 青铜宝箱个数: {qingtong}, 黄金宝箱个数: {huangjin}, 铂金宝箱个数: {bojin},宝箱积分值:{jifenzhi}")

        text_result = (
            f"木质宝箱：{muzhi}个\n"
            f"青铜宝箱：{qingtong}个\n"
            f"黄金宝箱：{huangjin}个\n"
            f"铂金宝箱：{bojin}个\n"
            f"原始积分：{heji}\n"
            f"奖后积分：{jianghou}\n"
            "================\n"
            f"宝箱周：{lun}轮\n"
            f"不开木质：{bukaimuzhi}轮\n"
            f"不开铂金：{bukaibojin}轮\n"
            "================\n"
            "发送\"帮助\"查看说明"
        )
        print(text_result.strip())
        result.chain = [
            Plain(text_result.strip()),
        ]
        return result
    else:
        print("未找到带 X 的数据")
        return MessageChain([Plain("未找到带 X 的数据")])


async def guanzi(text: str) -> MessageChain:
    logger.info(f"处理领取全部罐子识别结果: {text}")
    # 提取所有带 X 的数据
    x_pattern = re.compile(r"X\d+")
    x_data = []
    for match in x_pattern.finditer(text):
        if len(x_data) < 3:
            x_data.append(get_number_from_word(match.group()))
    print(f"罐子拿到的内容{x_data}")
    if len(x_data) == 3:
        jin = x_data[0]  # 金罐子
        yin = x_data[1]  # 银罐子
        tong = x_data[2]  # 铜罐子

        # 计算保底获得金砖数量
        baodi = jin * 160 + yin * 100 + tong * 40
        # 计算预计获得金砖数量
        yuji = round(baodi * 1.15)

        result_text = (
            "识别囤罐子成功:\n"
            f"金罐子：{jin}个\n"
            f"银罐子：{yin}个\n"
            f"铜罐子：{tong}个\n"
            f"保底获得金砖：{baodi}\n"
            f"预计获得金砖{yuji}\n"
            "------------------------------\n"
            "罐子识别计算仅为预估,\n数据取值为大部分玩家平均数值,\n基数越大,误差越小"
        )
        return MessageChain([Plain(result_text)])
    else:
        print("未找到足够带 X 的数据来计算罐子数量")
        return MessageChain([Plain("识别错误,请重新截图")])
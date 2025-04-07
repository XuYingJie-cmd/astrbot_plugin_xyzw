import traceback
from astrbot.api.event import filter, AstrMessageEvent, MessageEventResult
from astrbot.api.star import Context, Star, register
from astrbot.api import logger
from astrbot.core.star.filter.event_message_type import EventMessageType
from data.plugins.astrbot_plugin_xyzw.api_collection import xyzw
from astrbot.api import logger, AstrBotConfig
from .config import GLOBAL_CONFIG

try:
    from paddleocr import PaddleOCR
    ocr = PaddleOCR(use_angle_cls=True, lang="ch", use_gpu=False)
    logger.info("PaddleOCR 初始化成功")
except Exception as e:
    logger.error(f"初始化 PaddleOCR 失败: {e}")
    ocr = None


@register("咸鱼之王", "咸鱼之王", "咸鱼之王算宝箱or金鱼or罐子", "1.0.0")
class MyPlugin(Star):
    def __init__(self, context: Context, config: AstrBotConfig = None):
        super().__init__(context)
        self.config = config or {}
        GLOBAL_CONFIG["date"] = config.get("date", "2025-5-31")
        GLOBAL_CONFIG["jieri"] = config.get("jieri")
        GLOBAL_CONFIG["jinzhuan"] = config.get("jinzhuan")
        GLOBAL_CONFIG["yugan"] = config.get("yugan")
        GLOBAL_CONFIG["baoxiang"] = config.get("baoxiang")
        GLOBAL_CONFIG["zhaomuling"] = config.get("zhaomuling")
        # 不需要在 __init__ 中再初始化，已经在全局初始化过了
        print("全局变量初始化完成")
        print(GLOBAL_CONFIG)

    @filter.event_message_type(EventMessageType.ALL)
    async def helloworld(self, event: AstrMessageEvent):
        global ocr  # 声明使用全局变量

        message_chain = event.get_messages()
        logger.info(message_chain)
        if message_chain:
            first_message = message_chain[0]
            try:
                if hasattr(first_message, 'type') and first_message.type == 'Image':
                    logger.info("是图片，开始进行 OCR 识别")
                    image_url = first_message.url
                    logger.info(f"图片 URL: {image_url}")

                    if ocr is not None:
                        # 执行 OCR 识别
                        result = ocr.ocr(image_url, cls=True)
                        if result and result[0] is not None:
                            all_text = ''.join([line[1][0] for line in result[0]])
                            logger.info(f"识别结果汇总: {all_text}")

                            if "主线关卡" in all_text:
                                text = await xyzw.suanjinyu(all_text)
                                await event.send(text)
                            elif "积分值" in all_text:
                                text = await xyzw.baoxiang(all_text)
                                await event.send(text)
                            elif "领取全部罐子" in all_text:
                                text = await xyzw.guanzi(all_text)
                                await event.send(text)
                        else:
                            logger.info("未识别到文字")
                    else:
                        logger.error("PaddleOCR 未成功初始化，无法进行识别")

            except Exception as e:
                error_info = traceback.format_exc()
                logger.error(f"OCR 识别出错: {e}")
                print(error_info)
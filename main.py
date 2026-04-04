import asyncio, random

from os import getenv
from dotenv import load_dotenv

from aiogram import Bot, Dispatcher, types
from aiogram.types import Message
from aiogram import F
from aiogram.filters import Command
from aiogram.client.session.aiohttp import AiohttpSession

load_dotenv()

TOKEN = getenv("TOKEN")
PROXY = getenv("SOCKS5_PROXY")
BOT_VERSION = "0.3.0"

if PROXY:
    session = AiohttpSession(proxy=f"socks5://{PROXY}")
else:
    session = AiohttpSession()
bot = Bot(token=TOKEN, session=session)
dp = Dispatcher()

@dp.message(Command("start"))
async def start_command(message: types.Message):
    await message.reply(
        f"здарова!\n\n"
        "я оцениваю абсолюдно каждую пикчу, даже не смотря на то что там, и говорю процент дрочибельности на неё\n"
        "ПРОЦЕНТ ФОРМИРУЕТСЯ АВТОМАТИЧЕСКИ И Я НИКАК НЕ КОНТРОЛИРУЮ НА ЧТО БОТ ОТВЕТИТ\n\n"
        "этого бота сделал @m1lkydev\n\n"
        f"дрочибельно ли? {BOT_VERSION}"
    )

@dp.message(F.photo | F.video | F.sticker | F.animation | F.document)
async def catch_all(message: Message):  
    items = [
        "по моим расчётам\nэто недрочибельно, пошёл нахуй",
        "по моим расчётам\nна это можно гарантийно подрочить",
        "по моим расчётам\nна это можно подрочить на {value}%",
        "по моим расчётам\nна это можно вздрочнуть",
    ]
    weights = [
        5,
        0.7,
        85,
        0.1
    ]

    value = random.randint(1, 100)
    result = random.choices(items, weights=weights, k=1)[0].format(
        value=value
    )

    if random.choices([True, False], weights=[0.2, 50], k=1)[0] == True:
        result = "ваш САМЫЙ ДОСТОЙНЫЙ именитый эстонский эксперт кокоя\nСООБЩАЕТ ЧТООООООООООООООО\n\n" + result

    await message.reply(result)

async def main():
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
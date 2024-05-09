![header.jpg](https://github.com/Antonoko/playdate-chinese-IME/blob/main/__asset__/github_header.png?raw=true)

# Chinese/English IME for Playdate | 中英文输入法

这是一个可以在 Playdate 上以较高效率输入中文与英文的输入法。

支持功能：中文双拼单字输入、emoji 与快捷短语、英文与数字键盘、输入光标滚动。

提供了一个便签应用作为使用示例，你可以在 [release](https://github.com/Antonoko/playdate-chinese-IME/releases/tag/notes) 中下载后 sideload 体验。你也可以把输入法嵌入到你的游戏或应用中进行使用。

This is an input method that can input Chinese and English with high efficiency on Playdate.

Supported functions: Chinese double-pin single word input, emoji and shortcut phrases, English and numeric keyboard, input cursor scrolling.

A Notes application is provided as a usage example. You can download it in [release](https://github.com/Antonoko/playdate-chinese-IME/releases/tag/notes) and sideload on your Playdate to experience. You can also embed the input method into your game or application.

![CustomSkin.jpg](https://github.com/Antonoko/playdate-chinese-IME/blob/main/__asset__/CustomSkin.png?raw=true)

## 如何使用 notes 与电脑端的同步编辑工具？
![sync-tool-screenshot.png](https://github.com/Antonoko/playdate-chinese-IME/blob/main/__asset__/sync-tool-screenshot.png?raw=true)
1. 安装 [python](https://www.python.org/downloads/release/python-3119/)
2. 在 GitHub 顶部 `Code` 按钮中点击 `Download ZIP`
3. 解压后，进入目录 `sync-tool`
4. 在目录下执行命令：`pip install -r requirements.txt`，安装所需依赖
5. 在目录下执行 `python sync.py` 打开工具

tips:
- 在 excel 中编辑时，需要换行地方可以写 `\n`

## How to embed IME into your app
1. Duplicate files under `source` to your project directory;
2. Code snippet reference:
```lua
import 'ime'

-- initialization IME
local zh_ime = IME()

--Start calling the IME method
--IME:startRunning(header_hint, ui_lang, text_area_custom, keyboard_init)
-- header_hint: Title hint, string
-- ui_lang: You can specify the prompt title and UI language during input(zh/en)
-- text_area_custom: Character-by-character table
-- keyboard_init: Specified init keyboard as "zh", "en", "num"

zh_ime:startRunning("Input your text", "en", {"s","a","m","p","l","e"}, "en")
--zh_ime:startRunning("请输入笔记", "zh", {"示","例","文","本"}, "zh")

function playdate.update()
    gfx.sprite.update()

    -- Put it in update to continue receiving user input
    if zh_ime:isRunning() then   -- Ends when the user submits/exits the input method
        -- text_input: user's input content, return as split table
        text_input = zh_ime:update()
    else
        print("user input:"..concatenateStrings(text_input))
        print("is user discard:"..zh_ime:isUserDiscard())   -- Check whether the user submitted the content normally or discarded it
    end
end
```

## Known issues
- 可能性能不佳

## Features wish to add
- [x] 实现一个简单的排版引擎来处理文本换行；
- [x] 通过 menu 切换文本编辑与光标编辑模式，支持光标移动修改；
- [x] 支持滚动编辑与显示；
- [ ] 支持限制输入字数；
- [x] 添加默认的进出入动画；
- [ ] 优化提升性能；

## Thanks

- 汉语拼音辞典：https://github.com/mapull/chinese-dictionary
- Playdate 中文支持项目：https://github.com/Antonoko/Chinese-font-for-playdate
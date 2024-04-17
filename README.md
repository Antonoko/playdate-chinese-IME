![header.jpg](https://github.com/Antonoko/playdate-chinese-IME/blob/notes/__asset__/github_header.png?raw=true)

# Chinese/English IME for Playdate | 中英文输入法

这是一个可以在 Playdate 上以较高效率输入中文与英文的输入法。

提供了一个便签应用作为使用示例，你可以在 [release](https://github.com/Antonoko/playdate-chinese-IME/releases/tag/notes) 中下载后 sideload 体验。你也可以把输入法嵌入到你的游戏或应用中进行使用。

This is an input method that can input Chinese and English with high efficiency on Playdate.

A Notes application is provided as a usage example. You can download it in [release](https://github.com/Antonoko/playdate-chinese-IME/releases/tag/notes) and sideload on your Playdate to experience. You can also embed the input method into your game or application.

## How to embed into your app
1. Duplicate files under `source` to your project directory;
2. Code snippet reference:
```lua
import 'ime'

-- initialization IME
-- You can specify the prompt title and UI language during input(zh/en)
local zh_ime = IME("Input your text", "en", "sample", {1,1,1,1,1,1})
--local zh_ime = IME("请输入笔记", "zh", "示例文本", {3,3,3,3})

--Start calling the IME method
zh_ime:startRunning()

function playdate.update()
    gfx.sprite.update()

    -- Put it in update to continue receiving user input
    if zh_ime:isRunning() then   -- Ends when the user submits/exits the input method
        -- text_input: user's input content
        -- text_input_per_char_width: a table store per char's width (zh:3, en:1)
        text_input, text_input_per_char_width = zh_ime:update()
    end

    print(zh_ime:isUserDiscard())   -- Check whether the user submitted the content normally or discarded it
end
```

## Known issues
- 由于使用了 playdate.graphics.drawTextInRect 来进行文本排版，在折行时，最后一个中文汉字可能不会被显示（overflow 了）。文本内容是在的，只是不能被正确排版显示出来。
    - 可能原因：lua 对 unicode 支持有限；playdate 字体引擎对中文文字属性处理不佳；

## Features wish to add
- 实现一个简单的排版引擎来处理文本换行；
- 通过 menu 切换文本编辑与光标编辑模式，支持光标移动修改；
- 支持滚动编辑与显示；
- 支持限制输入字数；
- 添加默认的进出入动画；
- 优化提升性能；
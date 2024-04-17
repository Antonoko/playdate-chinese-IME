# Chinese/English IME for Playdate | 中英文输入法

这是一个可以在 Playdate 上以较高效率输入中文与英文的输入法。

提供了一个便签应用作为使用示例，你可以在 release 中下载后 sideload 体验。你也可以把输入法嵌入到你的游戏或应用中进行使用。

This is an input method that can input Chinese and English with high efficiency on Playdate.

A Notes application is provided as a usage example. You can download it in release and sideload on your Playdate to experience. You can also embed the input method into your game or application.

## How to embed into your app
1. Duplicate files at `source` into your project directory;
2. Code snippet reference:
```lua
import 'ime'

-- initialization IME
-- You can specify the prompt title and UI language during input(zh/en)
local zh_ime = IME("Input your text", "en")
--local zh_ime = IME("请输入笔记", "zh")

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

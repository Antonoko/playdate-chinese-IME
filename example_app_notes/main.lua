import 'CoreLibs/graphics'
import "CoreLibs/ui"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/sprites"

import 'ime'

local pd <const> = playdate
local gfx <const> = playdate.graphics
local screenWidth <const> = playdate.display.getWidth()
local screenHeight <const> = playdate.display.getHeight()

local zh_ime = IME("Input your text", "zh")
zh_ime:startRunning()



function init()

end


function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()

    if zh_ime:isRunning() then
        res = zh_ime:update()
    end

end
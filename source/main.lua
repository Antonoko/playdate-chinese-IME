import 'CoreLibs/graphics'
import "CoreLibs/ui"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics
local screenWidth <const> = playdate.display.getWidth()
local screenHeight <const> = playdate.display.getHeight()

local keyboard_choose = "zh"

local CAPS_IMG = gfx.imagetable.new("img/keyboard_caps")
local CAP_SIZE <const> = {
    x = 32,
    y = 28,
}
local CAPS_MAP_SPRITE_ZH <const> = {
    {
        name = "Q",
        index = 1,
        sprite = gfx.sprite.new(CAPS_IMG[1])
    },
    {
        name = "W",
        index = 2,
        sprite = gfx.sprite.new(CAPS_IMG[2])
    },
    {
        name = "E",
        index = 3,
        sprite = gfx.sprite.new(CAPS_IMG[3])
    },
    {
        name = "R",
        index = 4,
        sprite = gfx.sprite.new(CAPS_IMG[4])
    },
    {
        name = "T",
        index = 5,
        sprite = gfx.sprite.new(CAPS_IMG[5])
    },
    {
        name = "Y",
        index = 6,
        sprite = gfx.sprite.new(CAPS_IMG[6])
    },
    {
        name = "U",
        index = 7,
        sprite = gfx.sprite.new(CAPS_IMG[7])
    },
    {
        name = "I",
        index = 8,
        sprite = gfx.sprite.new(CAPS_IMG[8])
    },
    {
        name = "O",
        index = 9,
        sprite = gfx.sprite.new(CAPS_IMG[9])
    },
    {
        name = "P",
        index = 10,
        sprite = gfx.sprite.new(CAPS_IMG[10])
    },
    {
        name = "A",
        index = 11,
        sprite = gfx.sprite.new(CAPS_IMG[11])
    },
    {
        name = "S",
        index = 12,
        sprite = gfx.sprite.new(CAPS_IMG[12])
    },
    {
        name = "D",
        index = 13,
        sprite = gfx.sprite.new(CAPS_IMG[13])
    },
    {
        name = "F",
        index = 14,
        sprite = gfx.sprite.new(CAPS_IMG[14])
    },
    {
        name = "G",
        index = 15,
        sprite = gfx.sprite.new(CAPS_IMG[15])
    },
    {
        name = "H",
        index = 16,
        sprite = gfx.sprite.new(CAPS_IMG[16])
    },
    {
        name = "J",
        index = 17,
        sprite = gfx.sprite.new(CAPS_IMG[17])
    },
    {
        name = "K",
        index = 18,
        sprite = gfx.sprite.new(CAPS_IMG[18])
    },
    {
        name = "L",
        index = 19,
        sprite = gfx.sprite.new(CAPS_IMG[19])
    },
    {
        name = "Z",
        index = 20,
        sprite = gfx.sprite.new(CAPS_IMG[20])
    },
    {
        name = "X",
        index = 21,
        sprite = gfx.sprite.new(CAPS_IMG[21])
    },
    {
        name = "C",
        index = 22,
        sprite = gfx.sprite.new(CAPS_IMG[22])
    },
    {
        name = "V",
        index = 23,
        sprite = gfx.sprite.new(CAPS_IMG[23])
    },
    {
        name = "B",
        index = 24,
        sprite = gfx.sprite.new(CAPS_IMG[24])
    },
    {
        name = "N",
        index = 25,
        sprite = gfx.sprite.new(CAPS_IMG[25])
    },
    {
        name = "M",
        index = 26,
        sprite = gfx.sprite.new(CAPS_IMG[26])
    },
    {
        name = "COMMA",
        index = 27,
        sprite = gfx.sprite.new(CAPS_IMG[27])
    },
    {
        name = "PERIOD",
        index = 28,
        sprite = gfx.sprite.new(CAPS_IMG[28])
    },
}
local KEYBOARD_ZH_LAYOUT <const> = {
    10,
    9,
    9,
}
local VOWEL_LIST_OPTION <const> = json.decodeFile("data/zh_vowel.json")
local FONT = {
    roobert = {
        name = "roobert",
        font = gfx.font.new('font/Roobert-11-Medium')
    },
}

--------------------------------------------

function mapValue(old_value, old_min, old_max, new_min, new_max)
    return math.floor((old_value - old_min) * (new_max - new_min) / (old_max - old_min) + new_min)
end

--------------------------------------------

function draw_keyboard_zh()
    local line_cap_cnt = 1
    local line_cnt = 1

    for k, v in pairs(CAPS_MAP_SPRITE_ZH) do
        local pos = {
            x = (screenWidth - (CAP_SIZE.x * (KEYBOARD_ZH_LAYOUT[line_cnt] - 1)))/2 + (line_cap_cnt-1) * CAP_SIZE.x - 1 * (line_cap_cnt-1) ,
            y = (screenHeight - (CAP_SIZE.y * (#KEYBOARD_ZH_LAYOUT - 1)))/2 + (line_cnt-1) * CAP_SIZE.y - 1 * (line_cnt-1),
        }
        if v then
            v.sprite:moveTo(pos.x, pos.y)
            v.sprite:add()    
        end
        
        line_cap_cnt += 1
        if line_cap_cnt > KEYBOARD_ZH_LAYOUT[line_cnt] then
            line_cap_cnt = 1
            line_cnt += 1
        end
    end
end


function choose_cap(cap_name)
    if keyboard_choose == "zh" then
        local keyboard_map = CAPS_MAP_SPRITE_ZH
    end

    for k, v in pairs(keyboard_map) do
        if v then
            if v.name == cap_name then
                v.sprite:setImage(CAPS_IMG[v.index]:invertedImage())
            else
                v.sprite:setImage(CAPS_IMG[v.index])
            end
        end
    end
end


function draw_vowel_menu(initial_consonant, vowel, start_x)
    -- eg. initial_consonant: x, vowel: i
    if start_x == nil then
        start_x = 0
    end

    gfx.setFont(FONT["roobert"].font)
    local text_size = gfx.getTextSize("M")
    local line_height = text_size * 1.5
    local start_y = screenHeight - (#VOWEL_LIST_OPTION[initial_consonant][vowel] * line_height + 1)
    if start_y < 0 then
        start_y = 0
    end

    for i, j in ipairs(VOWEL_LIST_OPTION[initial_consonant][vowel]) do
        gfx.drawTextAligned(j, start_x, start_y + line_height * (i-1))
    end
end

--------------------------------------------

function init()
    -- draw_keyboard_zh()
    draw_vowel_menu("x", "i", 0)
end


function playdate.update()
    -- local crankPosition = playdate.getCrankPosition()
    -- local cap_select = mapValue(crankPosition, 0, 360, 1, #CAPS_MAP_SPRITE_ZH + 1)
    -- choose_cap(CAPS_MAP_SPRITE_ZH[cap_select].name)
    -- gfx.sprite.update()

    playdate.timer.updateTimers()
    
end

init()
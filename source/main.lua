import 'CoreLibs/graphics'
import "CoreLibs/ui"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = playdate.graphics
local screenWidth <const> = playdate.display.getWidth()
local screenHeight <const> = playdate.display.getHeight()

local keyboard_choose = "zh"
local cap_selection = "a"
local vowel_selection = "a"
local vowel_selection_result = "ni"
local candidate_words = ""
local text_area = "啊"
local text_area_sprite = gfx.sprite.new()
text_area_sprite:setCenter(0, 0)
text_area_sprite:moveTo(20,20)
text_area_sprite:add()

local cap_select_index = 1
local crank_offset = 0
local crankPosition_keyboard = 0
local stage_manager = "keyboard"
local STAGE = {}
local keyboard_map

local HALF_MASK_IMG <const> = gfx.image.new("img/white-mask2")
local HALF_MASK_SPRITE <const> = gfx.sprite.new(HALF_MASK_IMG)
HALF_MASK_SPRITE:moveTo(screenWidth/2, screenHeight/2)
HALF_MASK_SPRITE:setZIndex(100)

local DPAD_HINT_IMG <const> = gfx.imagetable.new("img/dpad_hint")
local dpad_hint_sprite = gfx.sprite.new(DPAD_HINT_IMG[1])
dpad_hint_sprite:moveTo(100,screenHeight-22)
dpad_hint_sprite:add()

local CAPS_SUB_IMG <const> = gfx.imagetable.new("img/keyboard_sub")
local caps_sub_sprite = gfx.sprite.new(CAPS_SUB_IMG[1])
caps_sub_sprite:moveTo(300,screenHeight-22)
caps_sub_sprite:add()

local CAPS_IMG <const> = gfx.imagetable.new("img/keyboard_caps")
local CAPS_IMG_PRESS <const> = gfx.imagetable.new("img/keyboard_caps_press")
local CAP_SIZE <const> = {
    x = 32,
    y = 26,
}
local CAPS_MAP_ZH <const> = {
    {
        name = "Q",
        index = 1,
        sprite = gfx.sprite.new(CAPS_IMG[1]),
        type = "consonant",
    },
    {
        name = "W",
        index = 2,
        sprite = gfx.sprite.new(CAPS_IMG[2]),
        type = "consonant",
    },
    {
        name = "E",
        index = 3,
        sprite = gfx.sprite.new(CAPS_IMG[3]),
        type = "vowel",
    },
    {
        name = "R",
        index = 4,
        sprite = gfx.sprite.new(CAPS_IMG[4]),
        type = "consonant",
    },
    {
        name = "T",
        index = 5,
        sprite = gfx.sprite.new(CAPS_IMG[5]),
        type = "consonant",
    },
    {
        name = "Y",
        index = 6,
        sprite = gfx.sprite.new(CAPS_IMG[6]),
        type = "consonant",
    },
    {
        name = "U",
        index = 7,
        sprite = gfx.sprite.new(CAPS_IMG[7]),
        type = "disable",
    },
    {
        name = "I",
        index = 8,
        sprite = gfx.sprite.new(CAPS_IMG[8]),
        type = "disable",
    },
    {
        name = "O",
        index = 9,
        sprite = gfx.sprite.new(CAPS_IMG[9]),
        type = "vowel",
    },
    {
        name = "P",
        index = 10,
        sprite = gfx.sprite.new(CAPS_IMG[10]),
        type = "consonant",
    },
    {
        name = "A",
        index = 11,
        sprite = gfx.sprite.new(CAPS_IMG[11]),
        type = "vowel",
    },
    {
        name = "S",
        index = 12,
        sprite = gfx.sprite.new(CAPS_IMG[12]),
        type = "consonant",
    },
    {
        name = "SH",
        index = 30,
        sprite = gfx.sprite.new(CAPS_IMG[30]),
        type = "consonant",
    },
    {
        name = "D",
        index = 13,
        sprite = gfx.sprite.new(CAPS_IMG[13]),
        type = "consonant",
    },
    {
        name = "F",
        index = 14,
        sprite = gfx.sprite.new(CAPS_IMG[14]),
        type = "consonant",
    },
    {
        name = "G",
        index = 15,
        sprite = gfx.sprite.new(CAPS_IMG[15]),
        type = "consonant",
    },
    {
        name = "H",
        index = 16,
        sprite = gfx.sprite.new(CAPS_IMG[16]),
        type = "consonant",
    },
    {
        name = "J",
        index = 17,
        sprite = gfx.sprite.new(CAPS_IMG[17]),
        type = "consonant",
    },
    {
        name = "K",
        index = 18,
        sprite = gfx.sprite.new(CAPS_IMG[18]),
        type = "consonant",
    },
    {
        name = "L",
        index = 19,
        sprite = gfx.sprite.new(CAPS_IMG[19]),
        type = "consonant",
    },
    {
        name = "Z",
        index = 20,
        sprite = gfx.sprite.new(CAPS_IMG[20]),
        type = "consonant",
    },
    {
        name = "ZH",
        index = 31,
        sprite = gfx.sprite.new(CAPS_IMG[31]),
        type = "consonant",
    },
    {
        name = "X",
        index = 21,
        sprite = gfx.sprite.new(CAPS_IMG[21]),
        type = "consonant",
    },
    {
        name = "C",
        index = 22,
        sprite = gfx.sprite.new(CAPS_IMG[22]),
        type = "consonant",
    },
    {
        name = "CH",
        index = 32,
        sprite = gfx.sprite.new(CAPS_IMG[32]),
        type = "consonant",
    },
    {
        name = "V",
        index = 23,
        sprite = gfx.sprite.new(CAPS_IMG[23]),
        type = "disable",
    },
    {
        name = "B",
        index = 24,
        sprite = gfx.sprite.new(CAPS_IMG[24]),
        type = "consonant",
    },
    {
        name = "N",
        index = 25,
        sprite = gfx.sprite.new(CAPS_IMG[25]),
        type = "consonant",
    },
    {
        name = "M",
        index = 26,
        sprite = gfx.sprite.new(CAPS_IMG[26]),
        type = "consonant",
    },
    {
        name = "SYMBOL",
        index = 29,
        sprite = gfx.sprite.new(CAPS_IMG[29]),
        type = "symbol",
    },
}
local KEYBOARD_ZH_LAYOUT <const> = {
    10,
    10,
    10,
}
local VOWEL_LIST_OPTION <const> = json.decodeFile("data/zh_vowel.json")
local ZH_WORD_LIST <const> = json.decodeFile("data/zh_word.json")
local FONT = {
    roobert = {
        name = "roobert",
        font = gfx.font.new('font/Roobert-11-Medium')
    },
    fusion_pixel_big = {
        name = "fusion-pixel-font-12px-proportional-zh_hans",
        font = gfx.font.new('font/fusion-pixel-font-12px-proportional-zh_hans')
    },
    source_san = {
        name = "SourceHanSansCN-M-24px",
        font = gfx.font.new('font/SourceHanSansCN-M-24px')
    },
}

--------------------------------------------utils

function mapValue(old_value, old_min, old_max, new_min, new_max)
    return math.floor((old_value - old_min) * (new_max - new_min) / (old_max - old_min) + new_min)
end

function tableHasKey(table, key)
    return table[key] ~= nil
end

function removeLastChar(str)
    return str:sub(1, -2) --en for -2
 end

--------------------------------------------core

function add_mask_between_keyboard_and_menu(active)
    if active then
        HALF_MASK_SPRITE:add()
    else
        HALF_MASK_SPRITE:remove()
    end
end

function switch_keyboard()
    if keyboard_choose == "zh" then
        keyboard_map = CAPS_MAP_ZH
    end
end


function draw_keyboard_zh()
    local line_cap_cnt = 1
    local line_cnt = 1

    for k, v in pairs(CAPS_MAP_ZH) do
        local pos = {
            x = (screenWidth - (CAP_SIZE.x * (KEYBOARD_ZH_LAYOUT[line_cnt] - 1)))/2 + (line_cap_cnt-1) * CAP_SIZE.x - 1 * (line_cap_cnt-1) ,
            y = (screenHeight - (CAP_SIZE.y * (#KEYBOARD_ZH_LAYOUT - 1)))*(7/10) + (line_cnt-1) * CAP_SIZE.y - 1 * (line_cnt-1),
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


function draw_keyboard_hint()
    local image = gfx.image.new(43, 36)
    gfx.pushContext(image)
        if tableHasKey(VOWEL_LIST_OPTION, cap_selection) then
            DPAD_HINT_IMG[1]:draw(0, 0)
            if tableHasKey(VOWEL_LIST_OPTION[cap_selection], "a") then
                DPAD_HINT_IMG[2]:draw(0, 0)
            end
            if tableHasKey(VOWEL_LIST_OPTION[cap_selection], "i") then
                DPAD_HINT_IMG[3]:draw(0, 0)
            end
            if tableHasKey(VOWEL_LIST_OPTION[cap_selection], "u") then
                DPAD_HINT_IMG[4]:draw(0, 0)
            end
            if tableHasKey(VOWEL_LIST_OPTION[cap_selection], "eov") then
                DPAD_HINT_IMG[5]:draw(0, 0)
            end
        end
    gfx.popContext()
    dpad_hint_sprite:setImage(image)
end


function choose_cap(cap_name)
    cap_selection = string.lower(cap_name)
    draw_keyboard_hint()
    for k, v in pairs(keyboard_map) do
        if v then
            if v.name == cap_name then
                v.sprite:setImage(CAPS_IMG_PRESS[v.index])
            else
                v.sprite:setImage(CAPS_IMG[v.index])
            end
        end
    end
end


function check_if_consonant_and_vowel_in_table(initial_consonant, vowel)
    if tableHasKey(VOWEL_LIST_OPTION, initial_consonant) then
        if tableHasKey(VOWEL_LIST_OPTION[initial_consonant], vowel) then
            return true
        else
            print(initial_consonant..vowel.." not found.")
            return false
        end
    else
        print(initial_consonant.." not found.")
        return false
    end
end


local drawVowelMenu_init = false
local drawVowelMenu_text_size, drawVowelMenu_gridview, drawVowelMenu_gridviewSprite
function drawVowelMenu(initial_consonant, vowel)
    if not check_if_consonant_and_vowel_in_table(initial_consonant, vowel) then
        return
    end

    if drawVowelMenu_init == false then
        gfx.setFont(FONT["roobert"].font)
        drawVowelMenu_text_size = gfx.getTextSize("M")
        drawVowelMenu_gridview = pd.ui.gridview.new(0, drawVowelMenu_text_size*1.5)
        drawVowelMenu_gridview:setNumberOfRows(#VOWEL_LIST_OPTION[initial_consonant][vowel])
        -- drawVowelMenu_gridview:setCellPadding(4,4,4,4)

        drawVowelMenu_gridviewSprite = gfx.sprite.new()
        drawVowelMenu_gridviewSprite:setCenter(0,0)
        drawVowelMenu_gridviewSprite:moveTo(200, 120)
        drawVowelMenu_gridviewSprite:setZIndex(200)
        drawVowelMenu_gridviewSprite:add()

        add_mask_between_keyboard_and_menu(true)
        
        drawVowelMenu_init = true
    end

    function drawVowelMenu_gridview:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        gfx.setFont(FONT["roobert"].font)
        gfx.drawTextAligned(VOWEL_LIST_OPTION[initial_consonant][vowel][row], x+40, y)
    end

    ----------------------draw
    if drawVowelMenu_gridview.needsDisplay then
        local pos = {
            x=200,
            y=drawVowelMenu_text_size*1.5*#VOWEL_LIST_OPTION[initial_consonant][vowel],
        }
        local gridviewImage = gfx.image.new(pos.x,pos.y)
        gfx.pushContext(gridviewImage)
            drawVowelMenu_gridview:drawInRect(0, 0, pos.x, pos.y)
        gfx.popContext()
        drawVowelMenu_gridviewSprite:setImage(gridviewImage)
        drawVowelMenu_gridviewSprite:moveTo(screenWidth*(1/4), screenHeight-pos.y-4)
    end

    local crankTicks = pd.getCrankTicks(10)
    if crankTicks == 1 then
        drawVowelMenu_gridview:selectNextRow(true)
    elseif crankTicks == -1 then
        drawVowelMenu_gridview:selectPreviousRow(true)
    end
    local _, selection_row, _ = drawVowelMenu_gridview:getSelection()
    vowel_selection_result = VOWEL_LIST_OPTION[initial_consonant][vowel][selection_row]

end


local drawZhWordMenu_init = false
local drawZhWordMenu_text_size, drawZhWordMenu_gridview, drawZhWordMenu_gridviewSprite, drawZhWordMenu_selection_index
function drawZhWordMenu(pingyin)
    if not tableHasKey(ZH_WORD_LIST, pingyin) then
        return
    end

    if drawZhWordMenu_init == false then
        drawZhWordMenu_selection_index = 1

        gfx.setFont(FONT["source_san"].font)
        drawZhWordMenu_text_size = gfx.getTextSize("我")
        drawZhWordMenu_gridview = pd.ui.gridview.new(drawZhWordMenu_text_size*1.5, drawZhWordMenu_text_size*1.5)
        drawZhWordMenu_gridview:setNumberOfRows((#ZH_WORD_LIST[pingyin] // 10) + 1)
        drawZhWordMenu_gridview:setNumberOfColumns(10)
        drawZhWordMenu_gridview:setCellPadding(2,2,2,2)
        drawZhWordMenu_gridview:setSectionHeaderHeight(24)

        drawZhWordMenu_gridviewSprite = gfx.sprite.new()
        drawZhWordMenu_gridviewSprite:moveTo(200, 120)
        drawZhWordMenu_gridviewSprite:setZIndex(300)
        drawZhWordMenu_gridviewSprite:add()

        add_mask_between_keyboard_and_menu(true)

        drawZhWordMenu_init = true
    end

    function drawZhWordMenu_gridview:drawSectionHeader(section, x, y, width, height)
        gfx.setFont(FONT["roobert"].font)
        gfx.drawTextAligned(pingyin, x+4, y+4, kTextAlignment.left)
    end

    function drawZhWordMenu_gridview:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        gfx.setFont(FONT["source_san"].font)
        if (((row-1)*10)+column) < #ZH_WORD_LIST[pingyin] + 1 then
            gfx.drawTextAligned(ZH_WORD_LIST[pingyin][((row-1)*10)+column], x+(drawZhWordMenu_text_size*1.5-drawZhWordMenu_text_size)/2, y+(drawZhWordMenu_text_size*1.5-drawZhWordMenu_text_size)/2)
        end
    end

    ----------------------draw
    if drawZhWordMenu_gridview.needsDisplay then
        local gridviewImage = gfx.image.new(400, 240)
        gfx.pushContext(gridviewImage)
            drawZhWordMenu_gridview:drawInRect(0, 0, 400, 240)
        gfx.popContext()
        drawZhWordMenu_gridviewSprite:setImage(gridviewImage)
    end

    local crankTicks = pd.getCrankTicks(20)
    if crankTicks == 1 then
        if not (drawZhWordMenu_selection_index > #ZH_WORD_LIST[pingyin] -1) then
            drawZhWordMenu_selection_index += 1
        end
    elseif crankTicks == -1 and drawZhWordMenu_selection_index > 1 then
        drawZhWordMenu_selection_index -= 1
    end

    local select_pos = {}
    if drawZhWordMenu_selection_index > 10 then
        if drawZhWordMenu_selection_index % 10 == 0 then
            select_pos["row"] = drawZhWordMenu_selection_index//10
            select_pos["column"] = 10
        else
            select_pos["row"] = drawZhWordMenu_selection_index//10 + 1
            select_pos["column"] = drawZhWordMenu_selection_index % 10
        end
    else
        select_pos["row"] = 1
        select_pos["column"] = drawZhWordMenu_selection_index
    end
    drawZhWordMenu_gridview:setSelection(1, select_pos.row, select_pos.column)

    candidate_words = ZH_WORD_LIST[pingyin][drawZhWordMenu_selection_index]
end

function updateTextAreaDisplay()
    local textImage = gfx.image.new(400, 240)
    gfx.pushContext(textImage)
        gfx.setFont(FONT["source_san"].font)
        gfx.drawText(text_area, 0, 0)
    gfx.popContext()
    text_area_sprite:setImage(textImage)
end

--------------------------------------------stage

STAGE["keyboard"] = function()
    switch_keyboard()

    crankPosition_keyboard = pd.getCrankPosition()
    crankPosition_keyboard = crankPosition_keyboard + crank_offset
    if crankPosition_keyboard > 360 then
        crankPosition_keyboard = math.floor(crankPosition_keyboard) % 360
    end
    cap_select_index = mapValue(crankPosition_keyboard, 0, 360, 1, #keyboard_map + 1)
    choose_cap(keyboard_map[cap_select_index].name)

    if pd.buttonJustPressed(pd.kButtonUp) then
        vowel_selection = "a"
        arrow_btn_pressed()
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        vowel_selection = "u"
        arrow_btn_pressed()
    elseif pd.buttonJustPressed(pd.kButtonLeft) then
        vowel_selection = "evo"
        arrow_btn_pressed()
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        vowel_selection = "i"
        arrow_btn_pressed()
    elseif pd.buttonJustPressed(pd.kButtonB) then
        text_area = removeLastChar(text_area)
    end

    function arrow_btn_pressed()
        if check_if_consonant_and_vowel_in_table(cap_selection, vowel_selection) then
            stage_manager = "vowel_menu"
        end    
    end
end


STAGE["vowel_menu"] = function()
    drawVowelMenu(cap_selection, vowel_selection)

    function exit_vowel_menu()
        if tableHasKey(ZH_WORD_LIST, vowel_selection_result) then
            stage_manager = "zh_word_menu"
        else
            stage_manager = "keyboard"
            add_mask_between_keyboard_and_menu(false)
        end
        drawVowelMenu_gridviewSprite:remove()
        drawVowelMenu_init = false
        crank_offset = math.abs(crankPosition_keyboard - pd.getCrankPosition())
    end

    if pd.buttonJustPressed(pd.kButtonUp) or pd.buttonJustReleased(pd.kButtonDown) or pd.buttonJustReleased(pd.kButtonLeft) or pd.buttonJustReleased(pd.kButtonRight) then
        exit_vowel_menu()
    end
end

STAGE["zh_word_menu"] = function()
    function exit_zh_word_menu()
        stage_manager = "keyboard"
        drawZhWordMenu_gridviewSprite:remove()
        drawZhWordMenu_init = false
        add_mask_between_keyboard_and_menu(false)
        crank_offset = math.abs(crankPosition_keyboard - pd.getCrankPosition())
    end

    drawZhWordMenu(vowel_selection_result)
    if pd.buttonJustPressed(pd.kButtonUp) or pd.buttonJustReleased(pd.kButtonDown) or pd.buttonJustReleased(pd.kButtonLeft) or pd.buttonJustReleased(pd.kButtonRight) then
        text_area = text_area..candidate_words
        exit_zh_word_menu()
    end
end

--------------------------------------------

function init()
    switch_keyboard()
    draw_keyboard_zh()
end


function pd.update()
    STAGE[stage_manager]()
    updateTextAreaDisplay()
    
    gfx.sprite.update()
    pd.timer.updateTimers()
end

init()
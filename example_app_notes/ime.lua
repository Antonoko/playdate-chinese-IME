import 'CoreLibs/graphics'
import "CoreLibs/ui"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = playdate.graphics
local screenWidth <const> = playdate.display.getWidth()
local screenHeight <const> = playdate.display.getHeight()

local zindex_start_offset <const> = 1000

local keyboard_choose = "zh"
local keyboard_choose_lazy_update = ""
local en_cap_lock = false
local en_cap_lock_lazy_update = false
local cap_selection = "a"
local cap_selection_lazy_update = ""
local vowel_selection = "a"
local vowel_selection_result = "ni"
local candidate_words = ""
local text_area_per_char_width = {}
local text_area = ""
local text_area_lazy_update = "."
local text_area_sprite = gfx.sprite.new()

local cap_select_index = 1
local cap_select_index_lazy_update = 1
local crank_offset = 0
local crankPosition_keyboard = 0
local stage_manager = "keyboard"
local STAGE = {}
local keyboard_map, keyboard_layout

local ime_menu = playdate.getSystemMenu()
local ime_is_running = false
local ime_is_user_discard = false

local HALF_MASK_IMG <const> = gfx.image.new("ime_src/img/white-mask2")
local HALF_MASK_SPRITE <const> = gfx.sprite.new(HALF_MASK_IMG)

local DPAD_HINT_IMG <const> = gfx.imagetable.new("ime_src/img/dpad_hint")
local dpad_hint_sprite = gfx.sprite.new(DPAD_HINT_IMG[1])

local CAPS_SUB_IMG <const> = gfx.imagetable.new("ime_src/img/keyboard_sub")
local caps_sub_sprite = gfx.sprite.new(CAPS_SUB_IMG[1])

local CAPS_IMG <const> = gfx.imagetable.new("ime_src/img/keyboard_caps")
local CAPS_IMG_PRESS <const> = gfx.imagetable.new("ime_src/img/keyboard_caps_press")
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
        type = "consonant",
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
        type = "consonant",
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
        type = "consonant",
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
local CAPS_MAP_EN <const> = {
    {
        name = "Q",
        index = 1,
        sprite = gfx.sprite.new(CAPS_IMG[1]),
        type = "alphabet",
    },
    {
        name = "W",
        index = 2,
        sprite = gfx.sprite.new(CAPS_IMG[2]),
        type = "alphabet",
    },
    {
        name = "E",
        index = 3,
        sprite = gfx.sprite.new(CAPS_IMG[3]),
        type = "alphabet",
    },
    {
        name = "R",
        index = 4,
        sprite = gfx.sprite.new(CAPS_IMG[4]),
        type = "alphabet",
    },
    {
        name = "T",
        index = 5,
        sprite = gfx.sprite.new(CAPS_IMG[5]),
        type = "alphabet",
    },
    {
        name = "Y",
        index = 6,
        sprite = gfx.sprite.new(CAPS_IMG[6]),
        type = "alphabet",
    },
    {
        name = "U",
        index = 7,
        sprite = gfx.sprite.new(CAPS_IMG[7]),
        type = "alphabet",
    },
    {
        name = "I",
        index = 8,
        sprite = gfx.sprite.new(CAPS_IMG[8]),
        type = "alphabet",
    },
    {
        name = "O",
        index = 9,
        sprite = gfx.sprite.new(CAPS_IMG[9]),
        type = "alphabet",
    },
    {
        name = "P",
        index = 10,
        sprite = gfx.sprite.new(CAPS_IMG[10]),
        type = "alphabet",
    },
    {
        name = "A",
        index = 11,
        sprite = gfx.sprite.new(CAPS_IMG[11]),
        type = "alphabet",
    },
    {
        name = "S",
        index = 12,
        sprite = gfx.sprite.new(CAPS_IMG[12]),
        type = "alphabet",
    },
    {
        name = "D",
        index = 13,
        sprite = gfx.sprite.new(CAPS_IMG[13]),
        type = "alphabet",
    },
    {
        name = "F",
        index = 14,
        sprite = gfx.sprite.new(CAPS_IMG[14]),
        type = "alphabet",
    },
    {
        name = "G",
        index = 15,
        sprite = gfx.sprite.new(CAPS_IMG[15]),
        type = "alphabet",
    },
    {
        name = "H",
        index = 16,
        sprite = gfx.sprite.new(CAPS_IMG[16]),
        type = "alphabet",
    },
    {
        name = "J",
        index = 17,
        sprite = gfx.sprite.new(CAPS_IMG[17]),
        type = "alphabet",
    },
    {
        name = "K",
        index = 18,
        sprite = gfx.sprite.new(CAPS_IMG[18]),
        type = "alphabet",
    },
    {
        name = "L",
        index = 19,
        sprite = gfx.sprite.new(CAPS_IMG[19]),
        type = "alphabet",
    },
    {
        name = "Z",
        index = 20,
        sprite = gfx.sprite.new(CAPS_IMG[20]),
        type = "alphabet",
    },
    {
        name = "X",
        index = 21,
        sprite = gfx.sprite.new(CAPS_IMG[21]),
        type = "alphabet",
    },
    {
        name = "C",
        index = 22,
        sprite = gfx.sprite.new(CAPS_IMG[22]),
        type = "alphabet",
    },
    {
        name = "V",
        index = 23,
        sprite = gfx.sprite.new(CAPS_IMG[23]),
        type = "alphabet",
    },
    {
        name = "B",
        index = 24,
        sprite = gfx.sprite.new(CAPS_IMG[24]),
        type = "alphabet",
    },
    {
        name = "N",
        index = 25,
        sprite = gfx.sprite.new(CAPS_IMG[25]),
        type = "alphabet",
    },
    {
        name = "M",
        index = 26,
        sprite = gfx.sprite.new(CAPS_IMG[26]),
        type = "consonant",
    },
    {
        name = "SYMBOL",
        index = 35,
        sprite = gfx.sprite.new(CAPS_IMG[35]),
        type = "symbol",
    },
}
local KEYBOARD_ZH_LAYOUT <const> = {
    10,
    10,
    10,
}
local KEYBOARD_EN_LAYOUT <const> = {
    10,
    9,
    8,
}
local KEYBOARD_CONFIG_LIST <const> = {
    zh = {
        keyboard_map = CAPS_MAP_ZH,
        keyboard_layout = KEYBOARD_ZH_LAYOUT,
        caps_sub_sprite_index = 1,
    },
    en = {
        keyboard_map = CAPS_MAP_EN,
        keyboard_layout = KEYBOARD_EN_LAYOUT,
        caps_sub_sprite_index = 2,
    },
}
local VOWEL_LIST_OPTION <const> = json.decodeFile("ime_src/data/zh_vowel.json")
local ZH_WORD_LIST <const> = json.decodeFile("ime_src/data/zh_word.json")
local FONT = {
    roobert = {
        name = "roobert",
        font = gfx.font.new('ime_src/font/Roobert-11-Medium')
    },
    fusion_pixel_12 = {
        name = "fusion-pixel-font-12px-proportional-zh_hans",
        font = gfx.font.new('ime_src/font/fusion-pixel-font-12px-proportional-zh_hans')
    },
    source_san = {
        name = "SourceHanSansCN-M-24px",
        font = gfx.font.new('ime_src/font/SourceHanSansCN-M-24px')
    },
    source_san_20 = {
        name = "SourceHanSansCN-M-20px",
        font = gfx.font.new('ime_src/font/SourceHanSansCN-M-20px')
    },
}
local SFX = {
    selection = {
        sound = pd.sound.fileplayer.new("ime_src/sound/selection")
    },
    selection_reverse = {
        sound = pd.sound.fileplayer.new("ime_src/sound/selection-reverse")
    },
    denial = {
        sound = pd.sound.fileplayer.new("ime_src/sound/denial")
    },
    key = {
        sound = pd.sound.fileplayer.new("ime_src/sound/key")
    }
}

--------------------------------------------utils

function mapValue(old_value, old_min, old_max, new_min, new_max)
    return math.floor((old_value - old_min) * (new_max - new_min) / (old_max - old_min) + new_min)
end

function tableHasKey(table, key)
    return table[key] ~= nil
end

function removeLastCharInTextArea(str)
    if #text_area_per_char_width > 0 then
        local remove_width = text_area_per_char_width[#text_area_per_char_width]
        table.remove(text_area_per_char_width, #text_area_per_char_width)
        return str:sub(1, -(1+remove_width)) --en for -2
    end
 end

--------------------------------------------core

function draw_header(header_text, lang)
    if header_text == nil then
        header_text = "请输入"
    end
    if lang == nil then
        lang = "en"
    end
    local lang_config = {
        zh = {
            img_table_index = 1
        },
        en = {
            img_table_index = 2
        },
    }
    local HEADER_IMG <const> = gfx.imagetable.new("ime_src/img/header_bg")
    local image = gfx.image.new(400, 45)
    gfx.pushContext(image)
        HEADER_IMG[lang_config[lang].img_table_index]:draw(0, 0)
        gfx.setFont(FONT["source_san_20"].font)
        gfx.setImageDrawMode(pd.graphics.kDrawModeFillWhite)
        gfx.drawTextAligned(header_text, 14, 7)
    gfx.popContext()
    local header_sprite = gfx.sprite.new(image)
    header_sprite:setCenter(0,0)
    header_sprite:moveTo(0, 0)
    header_sprite:setZIndex(1+zindex_start_offset)
    header_sprite:add()
end


function sidebar_option()
    local modeMenuItem, error = ime_menu:addMenuItem("Submit", function(value)
        print("Submit")
        ime_exit()
    end)
    
    local modeMenuItem, error = ime_menu:addMenuItem("Discard", function(value)
        print("Discard")
        text_area = ""
        ime_is_user_discard = true
        ime_exit()
    end)
end


function add_mask_between_keyboard_and_menu(active)
    if active then
        HALF_MASK_SPRITE:add()
    else
        HALF_MASK_SPRITE:remove()
    end
end

function switch_keyboard()
    if keyboard_choose ~= keyboard_choose_lazy_update then
        keyboard_map = KEYBOARD_CONFIG_LIST[keyboard_choose].keyboard_map
        keyboard_layout = KEYBOARD_CONFIG_LIST[keyboard_choose].keyboard_layout
        caps_sub_sprite:setImage(CAPS_SUB_IMG[KEYBOARD_CONFIG_LIST[keyboard_choose].caps_sub_sprite_index])

        keyboard_choose_lazy_update = keyboard_choose
    end
end


function switch_to_next_keyboard()
    -- FIXME: fuck lua disordered table
    clean_keyboard()
    if keyboard_choose == "en" then
        keyboard_choose = "zh"
    elseif keyboard_choose == "zh" then
        keyboard_choose = "en"
    end
    switch_keyboard()
    draw_keyboard()
end


function draw_keyboard()
    local line_cap_cnt = 1
    local line_cnt = 1
    local zindex_i = 0

    for k, v in pairs(keyboard_map) do
        local pos = {
            x = (screenWidth - (CAP_SIZE.x * (keyboard_layout[line_cnt] - 1)))/2 + (line_cap_cnt-1) * CAP_SIZE.x - 1 * (line_cap_cnt-1) + 15,
            y = (screenHeight - (CAP_SIZE.y * (#keyboard_layout - 1)))*(0.94) + (line_cnt-1) * CAP_SIZE.y - 1 * (line_cnt-1),
        }
        if v then
            v.sprite:moveTo(pos.x, pos.y)
            v.sprite:setZIndex(zindex_start_offset+zindex_i)
            v.sprite:add()
        end
        
        line_cap_cnt += 1
        if line_cap_cnt > keyboard_layout[line_cnt] then
            line_cap_cnt = 1
            line_cnt += 1
        end

        zindex_i += 1
    end
end


function clean_keyboard()
    for k, v in pairs(keyboard_map) do
        v.sprite:remove()
    end
end


function draw_keyboard_hint()
    if (cap_selection ~= cap_selection_lazy_update) or (cap_select_index ~= cap_select_index_lazy_update) or (en_cap_lock ~= en_cap_lock_lazy_update) then
        local image = gfx.image.new(43, 55)

        gfx.pushContext(image)
            DPAD_HINT_IMG[1]:draw(0, 0)
            if keyboard_choose == "en" then
                DPAD_HINT_IMG[1]:draw(0, 0)
                if en_cap_lock then
                    DPAD_HINT_IMG[9]:draw(0, 0)
                else
                    DPAD_HINT_IMG[8]:draw(0, 0)
                end
                if keyboard_map[cap_select_index].type == "symbol" then
                    DPAD_HINT_IMG[11]:draw(0, 0)
                else
                    DPAD_HINT_IMG[10]:draw(0, 0)
                end
            end

            if keyboard_choose == "zh" then
                DPAD_HINT_IMG[12]:draw(0, 0)
                if tableHasKey(VOWEL_LIST_OPTION, cap_selection) then
                    if keyboard_map[cap_select_index].type == "consonant" then
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
                    elseif keyboard_map[cap_select_index].type == "symbol" then
                        DPAD_HINT_IMG[6]:draw(0, 0)
                    elseif keyboard_map[cap_select_index].type == "disable" then
                        DPAD_HINT_IMG[7]:draw(0, 0)
                    end
                else
                    DPAD_HINT_IMG[7]:draw(0, 0)
                end
            end
        gfx.popContext()
        dpad_hint_sprite:setImage(image)

        cap_selection_lazy_update = cap_selection
        cap_select_index_lazy_update = cap_select_index
        en_cap_lock_lazy_update = en_cap_lock
    end
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


function en_cap_lock_switch()
    if en_cap_lock then
        en_cap_lock = false
    else
        en_cap_lock = true
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
function drawVowelMenu(initial_consonant, vowel, enable_zh_font)
    if not check_if_consonant_and_vowel_in_table(initial_consonant, vowel) then
        return
    end

    if drawVowelMenu_init == false then
        if enable_zh_font == true then
            gfx.setFont(FONT["source_san"].font)
            drawVowelMenu_text_size = gfx.getTextSize("我")
        else
            gfx.setFont(FONT["roobert"].font)
            drawVowelMenu_text_size = gfx.getTextSize("M")
        end
        drawVowelMenu_gridview = pd.ui.gridview.new(0, drawVowelMenu_text_size*1.5)
        drawVowelMenu_gridview:setNumberOfRows(#VOWEL_LIST_OPTION[initial_consonant][vowel])
        -- drawVowelMenu_gridview:setCellPadding(4,4,4,4)

        drawVowelMenu_gridviewSprite = gfx.sprite.new()
        drawVowelMenu_gridviewSprite:setCenter(0,0)
        drawVowelMenu_gridviewSprite:moveTo(200, 120)
        drawVowelMenu_gridviewSprite:setZIndex(200+zindex_start_offset)
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
        if enable_zh_font == true then
            gfx.setFont(FONT["source_san"].font)
            gfx.drawTextAligned(VOWEL_LIST_OPTION[initial_consonant][vowel][row], x+40, y+5)       
        else
            gfx.setFont(FONT["roobert"].font)
            gfx.drawTextAligned(VOWEL_LIST_OPTION[initial_consonant][vowel][row], x+40, y)
        end
    end

    local crankTicks = pd.getCrankTicks(10)
    local _, selection_row, _ = drawVowelMenu_gridview:getSelection()
    if (crankTicks == 1) and (selection_row < #VOWEL_LIST_OPTION[initial_consonant][vowel]) then
        drawVowelMenu_gridview:selectNextRow(true)
        SFX.selection.sound:play()
    elseif (crankTicks == -1) and (selection_row > 1) then
        drawVowelMenu_gridview:selectPreviousRow(true)
        SFX.selection_reverse.sound:play()
    end
    _, selection_row, _ = drawVowelMenu_gridview:getSelection()
    vowel_selection_result = VOWEL_LIST_OPTION[initial_consonant][vowel][selection_row]

    ----------------------draw
    if drawVowelMenu_gridview.needsDisplay then
        local pos = {
            x=200,
            y=drawVowelMenu_text_size*1.5*#VOWEL_LIST_OPTION[initial_consonant][vowel],
        }
        if pos.y > screenHeight then
            pos["y"] = screenHeight - 10
        end
        local gridviewImage = gfx.image.new(pos.x,pos.y)
        gfx.pushContext(gridviewImage)
            drawVowelMenu_gridview:drawInRect(0, 0, pos.x, pos.y)
        gfx.popContext()
        drawVowelMenu_gridviewSprite:setImage(gridviewImage)
        drawVowelMenu_gridviewSprite:moveTo(screenWidth*(1/4), screenHeight-pos.y-4)
    end

end


local drawZhWordMenu_init = false
local drawZhWordMenu_text_size, drawZhWordMenu_gridview, drawZhWordMenu_gridviewSprite, drawZhWordMenu_selection_index
function drawZhWordMenu(pinyin)
    if not tableHasKey(ZH_WORD_LIST, pinyin) then
        return
    end

    if drawZhWordMenu_init == false then
        drawZhWordMenu_selection_index = 1

        gfx.setFont(FONT["source_san"].font)
        drawZhWordMenu_text_size = gfx.getTextSize("我")
        drawZhWordMenu_gridview = pd.ui.gridview.new(drawZhWordMenu_text_size*1.5, drawZhWordMenu_text_size*1.5)
        drawZhWordMenu_gridview:setNumberOfRows((#ZH_WORD_LIST[pinyin] // 10) + 1)
        drawZhWordMenu_gridview:setNumberOfColumns(10)
        drawZhWordMenu_gridview:setCellPadding(2,2,2,2)
        drawZhWordMenu_gridview:setSectionHeaderHeight(24)

        drawZhWordMenu_gridviewSprite = gfx.sprite.new()
        drawZhWordMenu_gridviewSprite:moveTo(200, 120)
        drawZhWordMenu_gridviewSprite:setZIndex(300+zindex_start_offset)
        drawZhWordMenu_gridviewSprite:add()

        add_mask_between_keyboard_and_menu(true)

        drawZhWordMenu_init = true
    end

    function drawZhWordMenu_gridview:drawSectionHeader(section, x, y, width, height)
        gfx.setFont(FONT["roobert"].font)
        gfx.drawTextAligned(pinyin, x+4, y+4, kTextAlignment.left)
    end

    function drawZhWordMenu_gridview:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        gfx.setFont(FONT["source_san"].font)
        if (((row-1)*10)+column) < #ZH_WORD_LIST[pinyin] + 1 then
            gfx.drawTextAligned(ZH_WORD_LIST[pinyin][((row-1)*10)+column], x+(drawZhWordMenu_text_size*1.5-drawZhWordMenu_text_size)/2, y+(drawZhWordMenu_text_size*1.5-drawZhWordMenu_text_size)/2)
        end
    end

    local crankTicks = pd.getCrankTicks(20)
    if crankTicks == 1 then
        if not (drawZhWordMenu_selection_index > #ZH_WORD_LIST[pinyin] -1) then
            drawZhWordMenu_selection_index += 1
            SFX.selection.sound:play()
        end
    elseif crankTicks == -1 and drawZhWordMenu_selection_index > 1 then
        drawZhWordMenu_selection_index -= 1
        SFX.selection_reverse.sound:play()
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

    candidate_words = ZH_WORD_LIST[pinyin][drawZhWordMenu_selection_index]

    ----------------------draw
    if drawZhWordMenu_gridview.needsDisplay then
        local gridviewImage = gfx.image.new(400, 240)
        gfx.pushContext(gridviewImage)
            drawZhWordMenu_gridview:drawInRect(0, 0, 400, 240)
        gfx.popContext()
        drawZhWordMenu_gridviewSprite:setImage(gridviewImage)
    end

end

function updateTextAreaDisplay()
    if text_area ~= text_area_lazy_update then
        local textImage = gfx.image.new(350, 90)
        gfx.pushContext(textImage)
            gfx.setFont(FONT["source_san"].font)
            gfx.drawTextInRect(text_area.."|", 0, 0, 350, 90)
        gfx.popContext()
        text_area_sprite:setImage(textImage)
        text_area_lazy_update = text_area
    end
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

    if keyboard_choose == "en" then
        if pd.buttonJustPressed(pd.kButtonUp) then
            cap_type_state_switcher_en("u")
        elseif pd.buttonJustPressed(pd.kButtonDown) then
            cap_type_state_switcher_en("d")
        elseif pd.buttonJustPressed(pd.kButtonLeft) then
            cap_type_state_switcher_en("l")
        elseif pd.buttonJustPressed(pd.kButtonRight) then
            cap_type_state_switcher_en("r")
        end
    elseif keyboard_choose == "zh" then
        if pd.buttonJustPressed(pd.kButtonUp) then
            cap_type_state_switcher_zh("u")
        elseif pd.buttonJustPressed(pd.kButtonDown) then
            cap_type_state_switcher_zh("d")
        elseif pd.buttonJustPressed(pd.kButtonLeft) then
            cap_type_state_switcher_zh("l")
        elseif pd.buttonJustPressed(pd.kButtonRight) then
            cap_type_state_switcher_zh("r")
        end
    end

    ---universal operation
    if pd.buttonJustPressed(pd.kButtonB) then
        text_area = removeLastCharInTextArea(text_area)
        if text_area == nil then
            text_area = ""
        end
        SFX.key.sound:play()
    elseif pd.buttonJustPressed(pd.kButtonA) then
        switch_to_next_keyboard()
        SFX.key.sound:play()
    end

    function cap_type_state_switcher_zh(direction)
        if keyboard_map[cap_select_index].type == "consonant" then
            if direction == "u" then
                vowel_selection = "a"
            elseif direction == "d" then
                vowel_selection = "u"
            elseif direction == "l" then
                vowel_selection = "eov"
            elseif direction == "r" then
                vowel_selection = "i"
            end
            SFX.key.sound:play()
            active_vowel_menu()
        elseif keyboard_map[cap_select_index].type == "symbol" then
            if direction == "u" then
                text_area = text_area.."，"
                table.insert(text_area_per_char_width, 3)
            elseif direction == "d" then
                vowel_selection = "symbol"
                active_vowel_menu()
            elseif direction == "l" then
                vowel_selection = "sentence"
                active_vowel_menu()
            elseif direction == "r" then
                text_area = text_area.."。"
                table.insert(text_area_per_char_width, 3)
            end
            SFX.key.sound:play()
        elseif keyboard_map[cap_select_index].type == "disable" then
            SFX.denial.sound:play()
        end
    end


    function cap_type_state_switcher_en(direction)
        if keyboard_map[cap_select_index].type == "alphabet" then
            if direction == "l" then
                en_cap_lock_switch()
            else
                if en_cap_lock then
                    text_area = text_area..string.upper(keyboard_map[cap_select_index].name)
                else
                    text_area = text_area..string.lower(keyboard_map[cap_select_index].name)
                end
                table.insert(text_area_per_char_width, 1)
            end
            SFX.key.sound:play()
        elseif keyboard_map[cap_select_index].type == "symbol" then
            if direction == "u" then
                text_area = text_area..","
                table.insert(text_area_per_char_width, 1)
            elseif direction == "d" then
                vowel_selection = "symbol_en"
                active_vowel_menu()
            elseif direction == "l" then
                en_cap_lock_switch()
            elseif direction == "r" then
                text_area = text_area.." "
                table.insert(text_area_per_char_width, 1)
            end
            SFX.key.sound:play()
        end
    end


    function active_vowel_menu()
        if check_if_consonant_and_vowel_in_table(cap_selection, vowel_selection) then
            stage_manager = "vowel_menu"
        end    
    end

end


STAGE["vowel_menu"] = function()
    local enable_zh_font_display = false
    if cap_selection == "symbol" then
        enable_zh_font_display = true
    end
    drawVowelMenu(cap_selection, vowel_selection, enable_zh_font_display)

    function exit_vowel_menu()
        if tableHasKey(ZH_WORD_LIST, vowel_selection_result) then
            stage_manager = "zh_word_menu"
        elseif cap_selection == "symbol" then
            text_area = text_area..vowel_selection_result
            if vowel_selection == "symbol_en" then
                table.insert(text_area_per_char_width, 1)
            else
                table.insert(text_area_per_char_width, 3)
            end
            stage_manager = "keyboard"
            add_mask_between_keyboard_and_menu(false)
        else
            stage_manager = "keyboard"
            add_mask_between_keyboard_and_menu(false)
        end
        drawVowelMenu_gridviewSprite:remove()
        drawVowelMenu_init = false
        crank_offset = math.abs(crankPosition_keyboard - pd.getCrankPosition())
        SFX.key.sound:play()
    end

    if pd.buttonJustReleased(pd.kButtonUp) or pd.buttonJustReleased(pd.kButtonDown) or pd.buttonJustReleased(pd.kButtonLeft) or pd.buttonJustReleased(pd.kButtonRight) then
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
        SFX.key.sound:play()
    end

    drawZhWordMenu(vowel_selection_result)
    if pd.buttonJustPressed(pd.kButtonUp) or pd.buttonJustPressed(pd.kButtonDown) or pd.buttonJustPressed(pd.kButtonLeft) or pd.buttonJustPressed(pd.kButtonRight) then
        text_area = text_area..candidate_words
        table.insert(text_area_per_char_width, #candidate_words)
        exit_zh_word_menu()
    elseif pd.buttonJustPressed(pd.kButtonB) then
        exit_zh_word_menu()
    end
end

--------------------------------------------

function ime_exit()
    ime_menu:removeAllMenuItems()
    gfx.sprite.removeAll()
    ime_is_running = false
end


class('IME').extends()
function IME:init()
    -- header_hint: "Input your text"
    -- header_hint: "zh" / "en"
	IME.super.init(self)
end

function IME:startRunning(header_hint, ui_lang, text_area_custom, text_area_per_char_width_custom)
    ime_is_running = true
    ime_is_user_discard = false
    ime_menu:removeAllMenuItems()

    if header_hint == nil then
        self.header_hint = "Text Input"
    else
        self.header_hint = header_hint
    end
    if ui_lang == nil then
        self.ui_lang = "en"
    else
        self.ui_lang = ui_lang
    end
    if text_area_custom == nil or text_area_per_char_width_custom == nil then
    else
        text_area = text_area_custom
        text_area_per_char_width = text_area_per_char_width_custom
    end

    text_area_sprite:setCenter(0, 0)
    text_area_sprite:moveTo(25,55)
    text_area_sprite:setZIndex(40+zindex_start_offset)
    text_area_sprite:add()
    HALF_MASK_SPRITE:moveTo(screenWidth/2, screenHeight/2)
    HALF_MASK_SPRITE:setZIndex(100+zindex_start_offset)
    dpad_hint_sprite:setCenter(0,0)
    dpad_hint_sprite:moveTo(6,screenHeight-60)
    dpad_hint_sprite:setZIndex(30+zindex_start_offset)
    dpad_hint_sprite:add()
    caps_sub_sprite:setCenter(0,0)
    caps_sub_sprite:moveTo(370,screenHeight-45)
    caps_sub_sprite:setZIndex(31+zindex_start_offset)
    caps_sub_sprite:add()

    draw_header(self.header_hint, self.ui_lang)
    sidebar_option()
    switch_keyboard()
    draw_keyboard()
end

function IME:update()
    STAGE[stage_manager]()
    updateTextAreaDisplay()
    return text_area, text_area_per_char_width
end

function IME:isRunning()
    return ime_is_running
end

function IME:isUserDiscard()
    return ime_is_user_discard
end
import 'CoreLibs/graphics'
import "CoreLibs/ui"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/sprites"
import "CoreLibs/animation"
import "CoreLibs/animator"
import "CoreLibs/easing"

import 'ime'

local pd <const> = playdate
local gfx <const> = playdate.graphics
local screenWidth <const> = playdate.display.getWidth()
local screenHeight <const> = playdate.display.getHeight()

local IMG_ABOUT <const> = gfx.image.new("img/about")
playdate.setMenuImage(IMG_ABOUT)

local WHITE_MASK_IMG <const> = gfx.image.new("img/white")
local WHITE_MASK_SPRITE = gfx.sprite.new(WHITE_MASK_IMG)
WHITE_MASK_SPRITE:setCenter(0,0)
WHITE_MASK_SPRITE:moveTo(0,0)

local NOTE_TIP <const> = gfx.image.new("img/note_tip")
local NOTE_TIP_SPRITE = gfx.sprite.new(NOTE_TIP)
NOTE_TIP_SPRITE:setCenter(0,0)
NOTE_TIP_SPRITE:moveTo(0,screenHeight-32)

local NOTE_CONTENT_SPRITE = gfx.sprite.new()
NOTE_CONTENT_SPRITE:setCenter(0,0)
NOTE_CONTENT_SPRITE:moveTo(0,0)


local FONT = {
    source_san_20 = {
        name = "SourceHanSansCN-M-20px",
        font = gfx.font.new('img/font/SourceHanSansCN-M-20px')
    },
    Roobert_10 = {
        name = "Roobert-10-Bold",
        font = gfx.font.new('img/font/Roobert-10-Bold')
    },
    Roobert_10_halved = {
        name = "Roobert-10-Bold-Halved",
        font = gfx.font.new('img/font/Roobert-10-Bold-Halved')
    },
    Asheville_Sans_24_Light = {
        name = "Asheville-Sans-24-Light",
        font = gfx.font.new('img/font/Asheville-Sans-24-Light')
    },
}
local SFX = {
    selection = {
        sound = pd.sound.fileplayer.new("sound/selection")
    },
    selection_reverse = {
        sound = pd.sound.fileplayer.new("sound/selection-reverse")
    },
    denial = {
        sound = pd.sound.fileplayer.new("sound/denial")
    },
    key = {
        sound = pd.sound.fileplayer.new("sound/key")
    },
    slide_in = {
        sound = pd.sound.fileplayer.new("sound/slide_in")
    },
    slide_out = {
        sound = pd.sound.fileplayer.new("sound/slide_out")
    },
    click = {
        sound = pd.sound.fileplayer.new("sound/click")
    }
}
local STAGE = {}
local stage_manager = "main_screen"

local zh_ime = IME()

local user_notes = {}
local current_select_note_index = 1
local editor_mode = "new"
local note_menu = playdate.getSystemMenu()

----------------utils

function get_time_now_as_string()
    local minute = playdate.getTime().minute
    if minute <10 then
        minute = "0"..minute
    end
    local second = playdate.getTime().second
    if second <10 then
        second = "0"..second
    end

    return playdate.getTime().year.."/"..playdate.getTime().month.."/"..playdate.getTime().day.."   "..playdate.getTime().hour..":"..minute..":"..second
end

local user_notes_default <const> = {
    {
        time = get_time_now_as_string(),
        note = "欢迎使用 notes！按 A 查看笔记，按 B 来添加新的笔记。",
        per_char_width = {3,3,3,3,1,1,1,1,1,1,3,3,1,1,1,3,3,3,3,3,3,1,1,1,3,3,3,3,3,3,3,3},
    },
    {
        time = "2024/4/17  11:56:01",
        note = "If all you have is a hammer, everything looks like a nail. 如果你手里只有一把锤子，那么所有东西看上去都像是钉子。",
        per_char_width = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
    },
    {
        time = "Send from haru",
        note = "我们生活在一个悲惨的世界里，而我们所能期待的最好结果，就是这样空虚而毫无意义的日子能不断继续下去，而不是因为某种意外戛然而止。",
        per_char_width = {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
    },
    {
        time = get_time_now_as_string(),
        note = "试着进入笔记后删除我吧！",
        per_char_width = {3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3},
    }
}

local user_notes_none <const> = {
    {
        time = get_time_now_as_string(),
        note = "欢迎使用 Notes！按 A 查看笔记，按 B 来添加新的笔记。",
        per_char_width = {3,3,3,3,1,1,1,1,1,1,3,3,1,1,1,3,3,3,3,3,3,1,1,1,3,3,3,3,3,3,3,3},
    }
}

-- Get a value from a table if it exists or return a default value
local get_or_default = function (table, key, expectedType, default)
	local value = table[key]
	if value == nil then
		return default
	else
		if type(value) ~= expectedType then
			print("Warning: value for key " .. key .. " is type " .. type(value) .. " but expected type " .. expectedType)
			return default
		end
		return value
	end
end


-- Save the state of the game to the datastore
function save_state()
	print("Saving state...")
	local state = {}

	playdate.datastore.write(state)
	print("State saved!")
end


-- Load the state of the game from the datastore
function load_state()
	print("Loading state...")
	local state = playdate.datastore.read()
	if state == nil then
		print("No state found, using defaults")
        state = {}
	else
		print("State found!")
	end

    user_notes = get_or_default(state, "user_notes", "table", user_notes_default)

end

-----------------


function add_white_under_keyboard(active)
    WHITE_MASK_SPRITE:setZIndex(500)
    if active then
        WHITE_MASK_SPRITE:add()
    else
        WHITE_MASK_SPRITE:remove()
    end
end


local draw_note_list_init = false
local draw_note_list_size, draw_note_list_gridview, draw_note_list_gridviewSprite, draw_note_list_selection_index
function draw_note_list()
    if #user_notes == 0 then
        user_notes = user_notes_none
    end

    if not draw_note_list_init then
        draw_note_list_selection_index = 1

        gfx.setFont(FONT["source_san_20"].font)
        draw_note_list_size = gfx.getTextSize("我")
        draw_note_list_gridview = pd.ui.gridview.new(0, draw_note_list_size*1.5*2+15)
        draw_note_list_gridview:setNumberOfRows((#user_notes))
        draw_note_list_gridview:setCellPadding(2,2,2,2)
        draw_note_list_gridview:setSectionHeaderHeight(42)

        draw_note_list_gridviewSprite = gfx.sprite.new()
        draw_note_list_gridviewSprite:setCenter(0,0)
        draw_note_list_gridviewSprite:moveTo(screenWidth, 0)
        draw_note_list_gridviewSprite:setZIndex(100)
        draw_note_list_gridviewSprite:add()
        
        note_menu:removeAllMenuItems()
        draw_note_list_init = true
    end


    function draw_note_list_gridview:drawSectionHeader(section, x, y, width, height)
        gfx.setFont(FONT["Asheville_Sans_24_Light"].font)
        gfx.drawTextAligned("notes™", x+14, y+8, kTextAlignment.left)
    end

    function draw_note_list_gridview:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        gfx.setFont(FONT["source_san_20"].font)
        gfx.drawTextInRect(string.sub(user_notes[row].note, 1, 96), x+10, y+5, 350, draw_note_list_size*1.5*2)
        gfx.setFont(FONT["Roobert_10_halved"].font)
        gfx.drawTextAligned(user_notes[row].time, x+385, y+55, kTextAlignment.right)
    end

    local crankTicks = pd.getCrankTicks(10)
    if crankTicks == 1 or pd.buttonJustPressed(pd.kButtonDown) then
        draw_note_list_gridview:selectNextRow(true)
        SFX.selection.sound:play()
    elseif crankTicks == -1 or pd.buttonJustPressed(pd.kButtonUp) then
        draw_note_list_gridview:selectPreviousRow(true)
        SFX.selection_reverse.sound:play()
    end
    _, current_select_note_index, _ = draw_note_list_gridview:getSelection()
    
    ----------------------draw
    if draw_note_list_gridview.needsDisplay then
        local pos = {
            x=screenWidth,
            y=screenHeight,
        }
        local gridviewImage = gfx.image.new(pos.x,pos.y)
        gfx.pushContext(gridviewImage)
            draw_note_list_gridview:drawInRect(0, 0, pos.x, pos.y)
        gfx.popContext()
        draw_note_list_gridviewSprite:setImage(gridviewImage)
    end

end


local draw_note_list_animation_init = false
local draw_note_list_animator
function draw_note_list_animation(type)
    if not draw_note_list_animation_init then
        if type == "out" then
            draw_note_list_animator = gfx.animator.new(300, 0, -screenWidth, playdate.easingFunctions.outQuart)
        elseif type == "in" then
            draw_note_list_animator = gfx.animator.new(300, -screenWidth, 0, playdate.easingFunctions.outQuart)
        end
        draw_note_list_animation_init = true
    else
        if not draw_note_list_animator:ended() then
            draw_note_list_gridviewSprite:moveTo(draw_note_list_animator:currentValue(),0)
        end
    end
end

local draw_note_page_init = false
function draw_note_page()
    if not draw_note_page_init then
        local image = gfx.image.new(400,240)
        gfx.pushContext(image)
            gfx.setFont(FONT["Roobert_10_halved"].font)
            gfx.drawTextAligned(user_notes[current_select_note_index].time, 10, 10)    
            gfx.setFont(FONT["source_san_20"].font)
            gfx.drawTextInRect(user_notes[current_select_note_index].note, 10, 35, 390, 200)    
        gfx.popContext()
        NOTE_CONTENT_SPRITE:add()
        NOTE_TIP_SPRITE:add()
        NOTE_CONTENT_SPRITE:setImage(image)

        note_sidebar_option()
        draw_note_page_init = true
    end
end


local draw_note_page_animation_init = false
local draw_note_page_animator
function draw_note_page_animation(type)
    if not draw_note_page_animation_init then
        if type == "out" then
            draw_note_page_animator = gfx.animator.new(300, 0, screenWidth, playdate.easingFunctions.outQuart)
        elseif type == "in" then
            draw_note_page_animator = gfx.animator.new(300, screenWidth, 0, playdate.easingFunctions.outQuart)
        end
        draw_note_page_animation_init = true
    else
        if not draw_note_page_animator:ended() then
            NOTE_TIP_SPRITE:moveTo(draw_note_page_animator:currentValue(), screenHeight-32)
            NOTE_CONTENT_SPRITE:moveTo(draw_note_page_animator:currentValue(), 0)
        end
    end

end


function note_sidebar_option()
    note_menu:removeAllMenuItems()
    local modeMenuItem, error = note_menu:addMenuItem("Delete", function(value)
        print("Deleted note"..current_select_note_index..":"..user_notes[current_select_note_index].note)
        table.remove(user_notes, current_select_note_index)
        save_state()
        draw_note_list_init = false
        draw_note_page_init = false
        draw_note_list_animation_init = false
        draw_note_page_animation_init = false
        stage_manager = "main_screen"
    end)
end

-----------------

STAGE["main_screen"] = function()
    draw_note_list()
    draw_note_list_animation("in")
    draw_note_page_animation("out")

    if pd.buttonJustPressed(pd.kButtonA) then
        SFX.click.sound:play()
        draw_note_list_animation_init = false
        draw_note_page_animation_init = false
        draw_note_page_init = false
        stage_manager = "note_details"
    elseif pd.buttonJustPressed(pd.kButtonB) then
        SFX.click.sound:play()
        add_white_under_keyboard(true)
        editor_mode = "new"
        zh_ime:startRunning("新建笔记", "zh", "", {})
        stage_manager = "note_edit"
    end
end


STAGE["note_details"] = function()
    draw_note_page()
    draw_note_list_animation("out")
    draw_note_page_animation("in")

    if pd.buttonJustPressed(pd.kButtonA) then
        SFX.click.sound:play()
        add_white_under_keyboard(true)
        editor_mode = "edit"
        zh_ime:startRunning("修改笔记", "zh", user_notes[current_select_note_index].note, user_notes[current_select_note_index].per_char_width)
        stage_manager = "note_edit"
    elseif pd.buttonJustPressed(pd.kButtonB) then
        SFX.slide_out.sound:play()
        draw_note_list_init = false
        draw_note_list_animation_init = false
        draw_note_page_animation_init = false
        stage_manager = "main_screen"
    end
end

local user_input_text, user_input_text_per_char_width
STAGE["note_edit"] = function()
    if zh_ime:isRunning() then
        user_input_text, user_input_text_per_char_width = zh_ime:update()
    else
        SFX.slide_out.sound:play()
        if #user_input_text > 0 and (not zh_ime:isUserDiscard()) then
            if editor_mode == "edit" then
                table.remove(user_notes, 1)
            end
            local note_to_insert = {
                time = get_time_now_as_string(),
                note = user_input_text,
                per_char_width = user_input_text_per_char_width,
            }
            table.insert(user_notes, 1, note_to_insert)    
            save_state()
        end
        add_white_under_keyboard(false)
        draw_note_list_animation_init = false
        draw_note_page_animation_init = false
        draw_note_list_init = false
        draw_note_page_init = false
        stage_manager = "main_screen"
    end
end


-----------------

function init()
    load_state()
end


function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()

    STAGE[stage_manager]()
end

init()
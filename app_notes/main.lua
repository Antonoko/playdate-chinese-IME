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

local NOTE_SCROLL_MAX_LIMIT_MINIMUM <const> = 50
local note_scroll_max_limit = NOTE_SCROLL_MAX_LIMIT_MINIMUM
local note_scroll_max_limit_buffer = 0
local note_scroll_offset = 1
local invert_color = false
local user_custom_name = {}

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

local SKIN_MAIN_TITLE_IMG <const> = gfx.imagetable.new("img/main_title")
local SKIN_NOTE_TITLE_IMG <const> = gfx.imagetable.new("img/note_title")
local theme = {
    default = {
        name = "default",
        main_img = SKIN_MAIN_TITLE_IMG[1],
        note_img = SKIN_NOTE_TITLE_IMG[1],
    },
    feishu = {
        name = "feishu",
        main_img = SKIN_MAIN_TITLE_IMG[2],
        note_img = SKIN_NOTE_TITLE_IMG[2],
    },
    notion = {
        name = "notion",
        main_img = SKIN_MAIN_TITLE_IMG[3],
        note_img = SKIN_NOTE_TITLE_IMG[3],
    },
    Windows = {
        name = "Windows",
        main_img = SKIN_MAIN_TITLE_IMG[4],
        note_img = SKIN_NOTE_TITLE_IMG[4],
    },
    Mac = {
        name = "Mac",
        main_img = SKIN_MAIN_TITLE_IMG[5],
        note_img = SKIN_NOTE_TITLE_IMG[5],
    },
    custom = {
        name = "custom",
        main_img = SKIN_MAIN_TITLE_IMG[6],
        note_img = SKIN_NOTE_TITLE_IMG[6],
    },
}
local theme_selection = "default"
local SKIN_NOTE_TITLE_SPRITE = gfx.sprite.new(theme[theme_selection].note_img)
SKIN_NOTE_TITLE_SPRITE:setCenter(0,0)
SKIN_NOTE_TITLE_SPRITE:moveTo(0,0)
local note_title_datetime_sprite = gfx.sprite.new()
note_title_datetime_sprite:setCenter(0,0)
note_title_datetime_sprite:moveTo(0,0)
local NOTE_CONTENT_SPRITE = gfx.sprite.new()
NOTE_CONTENT_SPRITE:setCenter(0,0)
NOTE_CONTENT_SPRITE:moveTo(0,0) 

local FONT = {
    source_san_20 = {
        name = "SourceHanSansCN-M-20px",
        font = gfx.font.new('img/font/SourceHanSansCN-M-20px')
    },
    LXGWWenKaiGBScreen_24 = {
        name = "LXGWWenKaiGBScreen-24px",
        font = gfx.font.new('img/font/LXGWWenKaiGBScreen-24px')
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

function concatenateStrings(strTable)
    return table.concat(strTable)
end

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
        note = {'欢', '迎', '使', '用', ' ', 'n', 'o', 't', 'e', 's', ' ', '2', '！', "\\n", '按', ' ', 'A', ' ', '查', '看', '笔', '记', '，', '按', ' ', 'B', ' ', '来', '添', '加', '新', '的', '笔', '记', '。', '\\n', '\\n', '更', '新', '：', '\\n', '-', ' ', '输', '入', '法', '支', '持', '换', '行', '、', '移', '动', '光', '标', '、', '滚', '屏', '了', '；', '\\n', '-', ' ', '新', '增', '若', '干', '主', '题', '，', '你', '也', '可', '以', '使', '用', '自', '定', '义', '的', '应', '用', '名', '；'},
    },
    {
        time = "2024/4/17  11:56:01",
        note = {'I', 'f', ' ', 'a', 'l', 'l', ' ', 'y', 'o', 'u', ' ', 'h', 'a', 'v', 'e', ' ', 'i', 's', ' ', 'a', ' ', 'h', 'a', 'm', 'm', 'e', 'r', ',', ' ', 'e', 'v', 'e', 'r', 'y', 't', 'h', 'i', 'n', 'g', ' ', 'l', 'o', 'o', 'k', 's', ' ', 'l', 'i', 'k', 'e', ' ', 'a', ' ', 'n', 'a', 'i', 'l', '.', '\\n', '如', '果', '你', '手', '里', '只', '有', '一', '把', '锤', '子', '，', '那', '么', '所', '有', '东', '西', '看', '上', '去', '都', '像', '是', '钉', '子', '。'},
    },
    {
        time = "Send from haru",
        note = {'我', '们', '生', '活', '在', '一', '个', '悲', '惨', '的', '世', '界', '里', '，', '而', '我', '们', '所', '能', '期', '待', '的', '最', '好', '结', '果', '，', '就', '是', '这', '样', '空', '虚', '而', '毫', '无', '意', '义', '的', '日', '子', '能', '不', '断', '继', '续', '下', '去', '，', '而', '不', '是', '因', '为', '某', '种', '意', '外', '戛', '然', '而', '止', '。'},
    },
    {
        time = get_time_now_as_string(),
        note = {'试', '着', '进', '入', '笔', '记', '后', '删', '除', '我', '吧', '！'},
    }
}

local user_notes_none <const> = {
    {
        time = get_time_now_as_string(),
        note = {'欢', '迎', '使', '用', ' ', 'n', 'o', 't', 'e', 's', '！', '按', ' ', 'A', ' ', '查', '看', '笔', '记', '，', '按', ' ', 'B', ' ', '来', '添', '加', '新', '的', '笔', '记', '。'},
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


function update_theme()
    SKIN_NOTE_TITLE_SPRITE:setImage(theme[theme_selection].note_img)
end

function update_note_title()
    local image = gfx.image.new(400,30)
    gfx.pushContext(image)
        gfx.setFont(FONT["Roobert_10_halved"].font)
        gfx.drawTextAligned(user_notes[current_select_note_index].time, 14, 8)
    gfx.popContext()
    note_title_datetime_sprite:setImage(image)
end

function shallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

function remove_char_at_table(table_in, char)
    local table_op = {}
    local length = #table_in
    if length > 40 then
        length = 40
    end

    for i = 1, length do
        if table_in[i] ~= char then
            table.insert(table_op, table_in[i])
        end
    end

    return table_op
end


-- Save the state of the game to the datastore
function save_state()
	print("Saving state...")
	local state = {}
    state["user_notes"] = user_notes
    state["theme_selection"] = theme_selection
    state["invert_color"] = invert_color
    state["user_custom_name"] = user_custom_name

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
    theme_selection = get_or_default(state, "theme_selection", "string", "default")
    invert_color = get_or_default(state, "invert_color", "boolean", false)
    user_custom_name = get_or_default(state, "user_custom_name", "table", {"自", "定", "义", "名", "字"})

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

        main_page_sidebar_option()
        draw_note_list_init = true
    end


    function draw_note_list_gridview:drawSectionHeader(section, x, y, width, height)
        theme[theme_selection].main_img:draw(x,y)
        if theme_selection == "custom" then
            gfx.setFont(FONT["LXGWWenKaiGBScreen_24"].font)
            gfx.drawTextAligned(concatenateStrings(user_custom_name), x+14, y+10, kTextAlignment.left)
        end
        -- gfx.setFont(FONT["Asheville_Sans_24_Light"].font)
        -- gfx.drawTextAligned("notes™", x+14, y+8, kTextAlignment.left)
    end

    function draw_note_list_gridview:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        gfx.setFont(FONT["source_san_20"].font)
        local ellipsis
        if #user_notes[row].note > 30 then
            ellipsis = "..."
        else
            ellipsis = ""
        end
        gfx.drawTextInRect(string.sub(concatenateStrings(remove_char_at_table(user_notes[row].note, "\\n")), 1, 96)..ellipsis, x+10, y+5, 350, draw_note_list_size*1.5*2)
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
    function _updateNotePageText()
        local image = gfx.image.new(400,240)
        gfx.pushContext(image)
            gfx.setFont(FONT["source_san_20"].font)
            local current_x = 10
            local current_y = 35 - note_scroll_offset
            local max_zh_char_size = gfx.getTextSize("啊")
            local lineheight = max_zh_char_size * 1.4
            note_scroll_max_limit_buffer = 0
            for key, char in pairs(user_notes[current_select_note_index].note) do
                if char == "\\n" then --\n 强制换行
                    current_x = 10
                    current_y += lineheight
                    note_scroll_max_limit_buffer += lineheight
                else
                    gfx.drawTextAligned(char, current_x, current_y, kTextAlignment.left)
                    current_x += gfx.getTextSize(char)
                end
                
                if current_x > 390 - max_zh_char_size then
                    current_x = 10
                    current_y += lineheight
                    note_scroll_max_limit_buffer += lineheight
                end
            end 

            if note_scroll_max_limit_buffer > NOTE_SCROLL_MAX_LIMIT_MINIMUM then
                note_scroll_max_limit = note_scroll_max_limit_buffer
            end
        gfx.popContext()
        NOTE_CONTENT_SPRITE:setImage(image)
    end

    if not draw_note_page_init then
        update_note_title()
        NOTE_CONTENT_SPRITE:add()
        SKIN_NOTE_TITLE_SPRITE:add()
        note_title_datetime_sprite:add()
        NOTE_TIP_SPRITE:add()
        note_sidebar_option()
        note_scroll_max_limit = NOTE_SCROLL_MAX_LIMIT_MINIMUM
        note_scroll_offset = 1
        _updateNotePageText()
        draw_note_page_init = true
    end

    local change, acceleratedChange = playdate.getCrankChange()
    if change ~= 0 then
        if note_scroll_offset > 0 and note_scroll_offset < note_scroll_max_limit then
            note_scroll_offset += change/2
            _updateNotePageText()
        elseif note_scroll_offset > note_scroll_max_limit then
            note_scroll_offset = note_scroll_max_limit - 1
        else
            note_scroll_offset = 1
        end
    end

    if playdate.buttonIsPressed( playdate.kButtonUp ) then
        if note_scroll_offset > 0 and note_scroll_offset < note_scroll_max_limit then
            note_scroll_offset -= 10
            _updateNotePageText()
        elseif note_scroll_offset > note_scroll_max_limit then
            note_scroll_offset = note_scroll_max_limit - 1
        else
            note_scroll_offset = 1
        end
    elseif playdate.buttonIsPressed( playdate.kButtonDown ) then
        if note_scroll_offset > 0 and note_scroll_offset < note_scroll_max_limit -4 then
            note_scroll_offset += 10
            _updateNotePageText()
        elseif note_scroll_offset > note_scroll_max_limit -4 then
            note_scroll_offset = note_scroll_max_limit - 1
        else
            note_scroll_offset = 1
        end
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
            SKIN_NOTE_TITLE_SPRITE:moveTo(draw_note_page_animator:currentValue(), 0)
            note_title_datetime_sprite:moveTo(draw_note_page_animator:currentValue(), 0)
            NOTE_CONTENT_SPRITE:moveTo(draw_note_page_animator:currentValue(), 0)
        end
    end

end


function note_sidebar_option()
    note_menu:removeAllMenuItems()
    local modeMenuItem, error = note_menu:addMenuItem("delete note", function(value)
        table.remove(user_notes, current_select_note_index)
        save_state()
        draw_note_list_init = false
        draw_note_page_init = false
        draw_note_list_animation_init = false
        draw_note_page_animation_init = false
        stage_manager = "main_screen"
    end)
end

function main_page_sidebar_option()
    note_menu:removeAllMenuItems()
    local theme_list = {
        "default",
        "feishu",
        "notion",
        "Windows",
        "Mac",
        "custom",
    }
    local modeMenuItem, error = note_menu:addOptionsMenuItem("Theme", theme_list, theme_selection, function(value)
        theme_selection = value
        update_theme()
        save_state()
    end)

    local modeMenuItem, error = note_menu:addMenuItem("Custom Name", function(value)
        add_white_under_keyboard(true)
        zh_ime:startRunning("自定义标题", "zh", user_custom_name)
        stage_manager = "edit_custom_name"
    end)

    local invertMenuItem, error = note_menu:addCheckmarkMenuItem("Night", invert_color, function(value)
        print("Checkmark menu item value changed to: ", value)
        invert_color = value
        setInverted(invert_color)
        save_state()
    end)

end

function setInverted(darkMode)
	inverted = darkMode
	playdate.display.setInverted(inverted)
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
        zh_ime:startRunning("新建笔记", "zh", {})
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
        zh_ime:startRunning("修改笔记", "zh", user_notes[current_select_note_index].note)
        stage_manager = "note_edit"
    elseif pd.buttonJustPressed(pd.kButtonB) then
        SFX.slide_out.sound:play()
        draw_note_list_init = false
        draw_note_list_animation_init = false
        draw_note_page_animation_init = false
        stage_manager = "main_screen"
    end
end

local user_input_text
STAGE["note_edit"] = function()
    if zh_ime:isRunning() then
        user_input_text = zh_ime:update()
    else
        SFX.slide_out.sound:play()
        if #user_input_text > 0 and (not zh_ime:isUserDiscard()) then
            if editor_mode == "edit" then
                table.remove(user_notes, 1)
            end
            local note_to_insert = {
                time = get_time_now_as_string(),
                note = user_input_text,
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

STAGE["edit_custom_name"] = function()
    if zh_ime:isRunning() then
        user_input_text = zh_ime:update()
    else
        SFX.slide_out.sound:play()
        if #user_input_text > 0 and (not zh_ime:isUserDiscard()) then
            user_custom_name = user_input_text
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
    update_theme()
    setInverted(invert_color)
end


function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()

    STAGE[stage_manager]()
end

init()
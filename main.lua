local love = require("love")

local field_manager = require("field.field_manager")

local field_config = require("configs.field_config")

local button = require("ui.button")

---@type field_manager
local g_field_manager = {}

---@type integer
local iteration_counter = 0

---@type integer
local y_size = 100

---@type integer
local x_size = 100

---@type integer
local lower_bar_height = 10

---@type integer
local right_bar_width = 250

---@type integer
local CONST_BOT_SIZE = 9

math.randomseed(os.time())

---@type boolean
local is_paused = false

function love.load()
    love.graphics.setBackgroundColor(1, 1, 0)

    local screen_x, screen_y = love.window.getMode()
    print(screen_x, screen_y)

    local _ = button.new(
        function()
            is_paused = not is_paused
        end,
        "PAUSE",
        screen_x - right_bar_width + 10,
        10
    )

    x_size = math.floor((screen_x
       - right_bar_width
    ) / CONST_BOT_SIZE)

    y_size = math.floor((screen_y
        - lower_bar_height )
        / CONST_BOT_SIZE)

    g_field_manager = field_manager.new(
        x_size, y_size, field_config.CONST_INITIAL_PLACEMENT_PROMILE)
    print(g_field_manager:get_field_sizes())

    local _ = g_field_manager:get_iteration()

    iteration_counter = iteration_counter + 1
end


function love.draw()
    love.graphics.setBackgroundColor(1, 1, 0)

    button.drawButtons()

    local match = {
        [1] = {1, 1, 1},
        [2] = {1, 0, 0},
        [3] = {0, 0, 1},
        [4] = {0, 1, 0},
    }

    ---@type (integer?)[][]
    local action_data_matrix = g_field_manager:get_action_data_matrix()

    for i = 1, #action_data_matrix do
        for ii = 1, #action_data_matrix[1] do

            ---@type integer?
            local action_data = action_data_matrix[i][ii]

            ---@type integer[]
            local color = action_data ~= 0
                and  match[action_data_matrix[i][ii]]
                or {0, 0, 0.1}

            love.graphics.setColor(color[1], color[2], color[3])
            love.graphics.rectangle(
                "fill",
                (i - 1) * CONST_BOT_SIZE,
                (ii - 1) * CONST_BOT_SIZE,
                CONST_BOT_SIZE,
                CONST_BOT_SIZE)
        end
    end
end


function love.update(dt)

    button.updateButtons()

    if is_paused then
        return
    end

    ---@type integer[]
    local iteration_result = g_field_manager:get_iteration()

    iteration_counter = iteration_counter + 1

    ---@type integer
    local bots_count = g_field_manager:count_bots()

    if bots_count < 10 then
        print("field FAILED!!!")

        collectgarbage("collect")
        g_field_manager = field_manager.new(
            x_size,
            y_size,
            field_config.CONST_INITIAL_PLACEMENT_PROMILE)

        iteration_counter = 0
    end
end

function love.keypressed(key, unicode)
      if (key=="p") then
        is_paused = not is_paused
    end
end

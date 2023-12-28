local field = require("field.field")

math.randomseed(os.clock())

---@type integer
local size_step = 100

---@type integer
local epochs = 1000

for i = 1, 1 do

    ---@type field
    local a = field.new(i * size_step, i * size_step, 50)

    ---@type integer
    local start_time_2 = os.clock()

    for _ = 1, epochs do

        ---@type field
        a:get_iteration()
    end

    ---@type integer
    local end_time_2 = os.clock()

    print("size " .. i * size_step .. " = " ..
              (end_time_2 - start_time_2) / epochs)
end

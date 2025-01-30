local args = { ... }
for k, v in ipairs(args) do
    print(k .. " : " .. v .. " of " .. type(v))
end

local argparse = require "argparse"

local parser = argparse()
print("parser type "..type(parser))

local is_visualized = parser:option("--visualize")
    :choices({
        "from_start",
        "from_set_moment",
        "never"
    })
local args1 = parser:parse()

for k, v in pairs(args1) do
    print("parsed " .. k .. " : " .. v .. " of " .. type(v))
end
print(#args)

print(args1.visualize .. " : " .. type(args1.visualize))

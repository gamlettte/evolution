---@type thread
local a = coroutine.create(
    function ()
        for i = 1, 10 do
            print("hello from a"..i)
            coroutine.yield()
        end
    end
)

local b = coroutine.create(
    function ()
        for i = 1, 12, 1 do

            print("hello from b"..i)

            coroutine.resume(a)

            coroutine.yield()
        end
    end
)

for _ = 1, 10, 1 do
    coroutine.resume(b)
end

print(coroutine.status(a))

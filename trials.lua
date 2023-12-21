local function f()
    for i = 1, 1000 do
        print(i)
    end
end

local co = coroutine.create(f)
coroutine.resume(co)
f()

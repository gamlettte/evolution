local love = require("love")

---@class button
---@field private _id integer
---@field private _code fun():nil
---@field private _text string
---@field private _x integer
---@field private _y integer
---@field private _rx integer
---@field private _ry integer
---@field private _text_color integer[]
---@field private _font love.graphics.Font
---@field private _color integer[]
---@field private _original_color integer[]
---@field private _is_hovered boolean
---@field private _is_clicked boolean
local button = {}
button.__index = button

---@type button[]
local buttons = {}

---@type love.graphics.Font
local originalFont = love.graphics.getFont()

---@public
---@param code fun()
---@param text string
---@param x integer
---@param y integer
---@param rx integer?
---@param ry integer?
---@param text_color integer[]?
---@param font love.graphics.Font?
---@param color integer[]?
---@return button
---@nodiscard
function button.new(code, text, x, y, rx, ry, text_color, font, color)

    color = color or {1, 0, 1}

    ---@type button
    local self = setmetatable({
        _id = #buttons + 1,
        _code = code,
        _text = text,
        _x = x,
        _y = y,
        _rx = rx or 0,
        _ry = ry or 0,
        _text_color = text_color or {0, 0, 0},
        _font = font or love.graphics.getFont(),
        _color = color,
        _original_color = color,
        _is_hovered = true,
        _is_clicked = false,
    }, button)

    table.insert(buttons, self)

    return self
end


---@private
---@param x integer
---@param y integer
---@return boolean
---@nodiscard
function button:is_coords_in(x, y)
    return x < self._x + self._font:getWidth(self._text) + 20
        and x > self._x
        and y < self._y + self._font:getHeight(self._text) + 20
        and y > self._y

end


---@private
function button:update()

    if not self:is_coords_in(love.mouse.getX(), love.mouse.getY()) then
        self._is_hovered = false
        self._color = self._original_color
        return
    end

    if not self._is_hovered then
        self._is_hovered = true
        self._color = {
            self._color[1] + 0.2,
            self._color[2] + 0.2,
            self._color[3] + 0.2,
        }
    end

    if not love.mouse.isDown(1) then
        self._is_clicked = false
        return
    end

    if not self._is_clicked then
        self._is_clicked = true
        self._code()
    end
end


---@private
function button:draw()
    love.graphics.setFont(self._font)

    love.graphics.setColor(self._color)
    love.graphics.rectangle(
        "fill",
        self._x,
        self._y,
        self._font:getWidth(self._text) + 20,
        self._font:getHeight(self._text) + 20,
        self._rx,
        self._ry)

    love.graphics.setColor(self._text_color)
    love.graphics.print(self._text, self._x + 10, self._y + 10)

    love.graphics.setColor(255,255,255)
    love.graphics.setFont(originalFont)
end

---@public
function button.updateButtons()
    for i, v in pairs(buttons) do
        v:update()
    end
end

---@public
function button.drawButtons()
    for i, v in pairs(buttons) do
        v:draw()
    end
end

return button

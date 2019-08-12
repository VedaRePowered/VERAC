local text = {}

local textBoxes = {}
local selectedTextBox = 0
local cursorBlink = 0
love.keyboard.setKeyRepeat(true)

function text.new(x, y, width, defaultText)
	local tb = {
		type = "text",
		x = x,
		y = y,
		w = width,
		h = love.graphics.getFont():getHeight(),
		text = defaultText or "",
		cursorPosition = 0,
		hovered = false,
		id = #textBoxes+1
	}
	textBoxes[tb.id] = tb
	return setmetatable(tb, {__index=text})
end

function text.updateBlink(delta)
	cursorBlink = (cursorBlink + delta) % 0.2
end

function text:update(k)
	local mouseX, mouseY = love.mouse.getPosition()
	local newHovered = mouseX >= self.x and mouseY >= self.y and mouseX <= self.x + self.w and mouseY <= self.y + self.h
	if newHovered then
		f.playfield.guiUseMouse()
	end

	if k.action.down then
		if newHovered then
			self.hovered = newHovered
			selectedTextBox = self.id
			local font = love.graphics.getFont()
			local closestDist = math.huge
			for c = 0, #self.text do
				local testPos = font:getWidth(string.sub(self.text, 1, c))+self.x
				if math.abs(testPos-mouseX) <= closestDist then
					closestDist = math.abs(testPos-mouseX)
					self.cursorPosition = c
				else
					break
				end
			end
		else
			if selectedTextBox == self.id then
				selectedTextBox = 0
			end
		end
	end
end

function text:draw()
	love.graphics.setLineWidth(2)
	local font = love.graphics.getFont()

	local cutoff = string.sub(self.text, 1, self.cursorPosition) .. (selectedTextBox == id and (cursorBlink > 0.1 and "." or " ") or "") .. string.sub(self.text, self.cursorPosition+1, -1)
	if font:getWidth(cutoff) >= self.w then
		for c = #self.text, 1, -1 do
			cutoff = string.sub(self.text, 1, c) .. "..."
			if font:getWidth(cutoff) < self.w then
				break
			end
		end
	end
	love.graphics.setColor(0.9, 0.9, 0.85)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
	if self.hovered then
		love.graphics.setColor(0.7, 0.7, 0.7)
	else
		love.graphics.setColor(0.6, 0.6, 0.6)
	end
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
	love.graphics.setColor(0.05, 0.08, 0.1)
	love.graphics.print(cutoff, self.x, self.y+self.h/2-font:getHeight()/2)

	love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key)
	local tb = textBoxes[selectedTextBox]
	if tb then
		local ignoreKeys = {
			lshift=true, rshift=true,
			lctrl=true, rctrl=true,
			escape=true
		}
		if ignoreKeys[key] then
		elseif key == "right" then
			tb.cursorPosition = math.min(#tb.text, tb.cursorPosition+1)
		elseif key == "left" then
			tb.cursorPosition = math.max(0, tb.cursorPosition-1)
		elseif key == "down" then
			tb.cursorPosition = #tb.text
		elseif key == "up" then
			tb.cursorPosition = 0
		elseif key == "backspace" then
			if tb.cursorPosition > 0 then
				tb.cursorPosition = tb.cursorPosition - 1
				tb.text = string.sub(tb.text, 1, tb.cursorPosition) .. string.sub(tb.text, tb.cursorPosition+2, -1)
			end
		elseif key == "delete" then
			tb.text = string.sub(tb.text, 1, tb.cursorPosition) .. string.sub(tb.text, tb.cursorPosition+2, -1)
		else
			if key == "space" then
				key = " "
			elseif key == "tab" then
				key = "\t"
			end
			if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
				local upperChars = {
					"!", "@", "#", "$", "%",
					"^", "&", "*", "(", ")",
					["["] = "{", ["]"] = "}",
					[";"] = ":", ["'"] = "\"",
					[","] = "<", ["."] = ">",
					["/"] = "?", ["\\"] = "|"
				}
				key = upperChars[key] or upperChars[tonumber(key)] or string.upper(key)
			end
			tb.text = string.sub(tb.text, 1, tb.cursorPosition) .. key .. string.sub(tb.text, tb.cursorPosition+1, -1)
			tb.cursorPosition = tb.cursorPosition + 1
		end
	end
end

return text

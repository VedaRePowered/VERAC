local selector = {}

function selector.new(x, y, itemList, selectionCallback)
	local font = love.graphics.getFont()
	local menu = {
		type = "menu",
		x = x,
		y = y,
		w = 100,
		h = font:getHeight()*#itemList,
		selected = 1,
		hovered = 0,
		items = itemList,
		callback = selectionCallback
	}
	local maxWidth = 100
	for _, t in ipairs(itemList) do
		maxWidth = math.max(font:getWidth(t), maxWidth)
	end
	return setmetatable(menu, {__index=selector})
end

function selector:update(k)
	local mouseX, mouseY = love.mouse.getPosition()
	local newHovered = mouseX >= self.x and mouseY >= self.y and mouseX <= self.x + self.w and mouseY <= self.y + self.h
	if newHovered then
		f.playfield.guiUseMouse()
	end

	if newHovered then
		self.hovered = math.ceil((mouseY-self.y)/love.graphics.getFont():getHeight())
		if k.action.down then
			if self.selected ~= self.hovered and self.callback then
				self:callback(self.hovered)
			end
			self.selected = self.hovered
		end
	else
		self.hovered = 0
	end
end

function selector:draw()
	love.graphics.setLineWidth(2)
	local font = love.graphics.getFont()

	local optionHeight = font:getHeight()
	love.graphics.setColor(0.8, 0.8, 0.75)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
	love.graphics.setColor(0.9, 0.9, 0.85)
	love.graphics.rectangle("fill", self.x, self.y+(self.selected-1)*optionHeight, self.w, optionHeight)
	if self.hovered ~= 0 then
		love.graphics.setColor(0.7, 0.7, 0.7)
		love.graphics.rectangle("line", self.x, self.y+(self.hovered-1)*optionHeight, self.w, optionHeight)
	end
	love.graphics.setColor(0.05, 0.08, 0.1)
	for i, t in ipairs(self.items) do
		love.graphics.print(t, self.x, self.y+(i-1)*optionHeight)
	end

	love.graphics.setColor(1, 1, 1)
end

return selector

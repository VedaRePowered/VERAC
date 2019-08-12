local button = {}

local gradiantShader = [[
uniform vec4 colourA;
uniform vec4 colourB;
uniform vec2 direction;

vec4 effect( vec4 colour, Image texture, vec2 textureCoords, vec2 screenCoords ) {
	return ( colourA * length(textureCoords*normalize(direction)) + colourB * (1-length(textureCoords*normalize(direction))) )*colour;
}]]
gradiantShader = love.graphics.newShader(gradiantShader)
local pixel = love.graphics.newImage(love.image.newImageData(1, 1))

function button.new(x, y, width, height, text, clickCallback)
	return setmetatable({
		type = "button",
		x = x,
		y = y,
		w = width,
		h = height,
		label = text,
		hovered = false,
		held = false,
		down = false,
		up = false,
		callback = clickCallback
	}, {__index=button})
end

function button:update(k)
	local mouseX, mouseY = love.mouse.getPosition()
	local newHovered = mouseX >= self.x and mouseY >= self.y and mouseX <= self.x + self.w and mouseY <= self.y + self.h
	if newHovered then
		f.playfield.guiUseMouse()
	end

	local newHeld = self.hovered and newHovered and k.action.down or newHovered and self.held and k.action.held
	self.down = newHeld and not self.held
	self.up = self.held and not newHeld
	self.hovered = newHovered
	self.held = newHeld

	if self.down and self.callback then
		self:callback()
	end
end

function button:draw()
	love.graphics.setLineWidth(2)
	local font = love.graphics.getFont()

	gradiantShader:send("direction", {0, 1})
	if self.hovered then
		love.graphics.setColor(1, 1, 1)
	else
		love.graphics.setColor(0.8, 0.8, 0.8)
	end
	if self.held then
		gradiantShader:sendColor("colourA", {0.7, 0.68, 0.63, 1})
		gradiantShader:sendColor("colourB", {0.4, 0.43, 0.43, 1})
	else
		gradiantShader:sendColor("colourA", {0.4, 0.42, 0.43, 1})
		gradiantShader:sendColor("colourB", {0.7, 0.7, 0.65, 1})
	end
	love.graphics.setShader(gradiantShader)
	love.graphics.draw(pixel, self.x, self.y, 0, self.w, self.h)
	love.graphics.setShader()
	if self.hovered then
		love.graphics.setColor(0.7, 0.7, 0.7)
	else
		love.graphics.setColor(0.6, 0.6, 0.6)
	end
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
	love.graphics.setColor(0.05, 0.08, 0.1)
	love.graphics.print(self.label, self.x+self.w/2-font:getWidth(self.label)/2, self.y+self.h/2-font:getHeight()/2)
	love.graphics.setColor(1, 1, 1)
end

return button

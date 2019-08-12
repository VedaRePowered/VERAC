local slider = {}
slider.clickedLast = false
slider.leftLast = false
slider.rightLast = false
slider.leftCooldown2Active = false
slider.rightCooldown2Active = false
slider.leftCooldown1 = 0
slider.rightCooldown1 = 0
slider.leftCooldown2 = 0
slider.rightCooldown2 = 0
slider.wheelDelta = 0

function slider.new(x, y, size, thickness, direction, setCallback)
	return setmetatable({
		x = x - size/2,
		y = y - thickness/2,
		width = size,
		height = thickness,
		c1 = {1.0, 1.0, 1.0},
		c2 = {0.8, 0.8, 0.8, 0.6},
		c3 = {0.8, 0.8, 0.8},
		c4 = {0.4, 0.4, 0.4},
		val = 0,
		grabbed = false,
		mouseOffset = 0,
		lastWheel = 0,
		callback=setCallback
	}, {__index=slider})
end

function slider.updateMouseKeys(delta, k)
	slider.leftCooldown1 = slider.leftCooldown1 - delta
	slider.rightCooldown1 = slider.rightCooldown1 - delta
	slider.leftCooldown2 = slider.leftCooldown2 - delta
	slider.rightCooldown2 = slider.rightCooldown2 - delta
	if love.mouse.isDown(1, 2, 3) then
		slider.clickedLast = true
	else
		slider.clickedLast = false
	end

	if k.sliderLeft.held and not slider.leftLast then
		slider.leftCooldown1 = 0.5
	end
	if k.sliderRight.held and not slider.rightLast then
		slider.rightCooldown1 = 0.5
	end
	slider.leftLast = k.sliderLeft.held
	slider.rightLast = k.sliderRight.held
	if not k.sliderLeft.held then
		slider.leftCooldown2Active = false
	end
	if not k.sliderRight.held then
		slider.rightCooldown2Active = false
	end
	if slider.leftLast and slider.leftCooldown1 <= 0 then
		slider.leftCooldown2Active = true
	end
	if slider.rightLast and slider.rightCooldown1 <= 0 then
		slider.rightCooldown2Active = true
	end
	if slider.leftCooldown2Active then
		if slider.leftCooldown2 <= 0 then
			slider.leftLast = false
			slider.leftCooldown2 = 0.1
		end
	else
		slider.leftCooldown2 = 0.1
	end
	if slider.rightCooldown2Active then
		if slider.rightCooldown2 <= 0 then
			slider.rightLast = false
			slider.rightCooldown2 = 0.1
		end
	else
		slider.rightCooldown2 = 0.1
	end
end

function slider:update(k)
	local oldVal = self.val

	self.val = math.max(math.min(self.val + (slider.wheelDelta - self.lastWheel), 1), 0)
	self.lastWheel = slider.wheelDelta

	local mouseX, mouseY = love.mouse.getPosition()
	if k.action.held then
		if (not self.grabbed) and mouseX >= self.x+self.val*(self.width-10)-10 and mouseY >= self.y-10 and mouseX <= self.x+self.val*(self.width-10)+10+10 and mouseY <= self.y+self.height+10 then
			if not slider.clickedLast then
				self.grabbed = true
				self.mouseOffset = self.val - math.max(math.min((mouseX - self.x) / self.width, 1), 0)
			end
		end
		if self.grabbed then
			self.val = math.max(math.min((mouseX - self.x) / self.width + self.mouseOffset, 1), 0)
		end
	else
		self.grabbed = false
	end

	if mouseX >= self.x - 10 and mouseY >= self.y - 10 and mouseX <= self.x + self.width + 10 and mouseY <= self.y + self.height + 10 then
		if k.sliderLeft.held and not slider.leftLast then
			if not self.grabbed then
				self.val = math.max(math.min(self.val - 0.05, 1), 0)
			else
				self.mouseOffset = self.mouseOffset - 0.05
			end
		end
		if k.sliderRight.held and not slider.rightLast then
			if not self.grabbed then
				self.val = math.max(math.min(self.val + 0.05, 1), 0)
			else
				self.mouseOffset = self.mouseOffset + 0.05
			end
		end
	end

	if self.callback and self.val ~= oldVal then
		self:callback(self.val)
	end
end

function slider:draw()
	love.graphics.setLineWidth(5)
	love.graphics.setColor(self.c1)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	if self.grabbed then
		love.graphics.setColor(self.c4)
	else
		love.graphics.setColor(self.c3)
	end
	love.graphics.rectangle("fill", self.x+self.val*(self.width-10), self.y, 10, self.height)
	love.graphics.setColor(self.c2)
	love.graphics.rectangle("line", self.x-2, self.y-2, self.width+4, self.height+4)
	love.graphics.setColor(1, 1, 1)
end

function love.wheelmoved(x, y)
	local mouseX, mouseY = love.mouse.getPosition()
	slider.wheelDelta = slider.wheelDelta - y/20
end

return slider

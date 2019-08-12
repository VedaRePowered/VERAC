local slider = {}

function slider.new(x, y, size, direction)
	return setmetatable({
	}, {__index=slider})
end

function slider:update(k)

end

function slider:draw()

end

return slider

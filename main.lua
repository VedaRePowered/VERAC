function love.load()
	_G.f = {} -- f for 'functions'
	local function load(module) f[tostring(module)] = require("func." .. tostring(module)) end
	load "camera"

	_G.s = { -- s for 'state'
		camera = f.camera.new
	}
end

function love.update(delta)

end

function love.draw()

end

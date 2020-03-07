function love.conf(t)
	-- General
	t.identity = nil -- no save data needed
	t.appendidentity = false
	t.version = "11.0" -- 0.9.0+ adds shaders, so it will work, won't warn on 11.*
	t.console = true
	t.accelerometerjoystick = false
	t.externalstorage = false
	t.gammacorrect = true
	t.audio.mixwithsystem = true

	-- Window
	t.window.title = "Racing Platformer"
	t.window.icon = "assets/icon.png"
	t.window.width = 1280
	t.window.height = 720
	t.window.borderless = false
	t.window.resizable = true
	t.window.minwidth = 480
	t.window.minheight = 360
	t.window.fullscreen = false
	t.window.fullscreentype = "desktop"
	t.window.vsync = 1
	t.window.msaa = 0
	t.window.depth = nil
	t.window.stencil = nil
	t.window.display = 1
	t.window.highdpi = false
	t.window.x = nil
	t.window.y = nil

	-- Modules TODO: disable unused modules
	t.modules.audio = true
	t.modules.data = true
	t.modules.event = true
	t.modules.font = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = true
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = true
	t.modules.sound = true
	t.modules.system = true
	t.modules.thread = true
	t.modules.timer = true
	t.modules.touch = true
	t.modules.video = true
	t.modules.window = true
end

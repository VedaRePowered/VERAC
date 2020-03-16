local gen = {}
g2d = require "func.generation.Grid2d"

function gen.world()
    local world = g2d.new(10,100)
    world:set(2,1,"hi")
    print("lemon")
    return world
end

return gen
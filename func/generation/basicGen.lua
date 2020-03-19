local gen = {}
g2d = require "func.generation.Grid2d"

--possible todo, have generator functions and populator functions

function basicPlatforms()
    local room = g2d.new(10,20)
    for x=1, 5 do room:set(x,1,"dirt") end
    for x=1, 5 do room:set(x,10,"stone") end

    return room
end

function noise()
    --generates noisy texture on either side of walls as proof of concept
    local room = g2d.new(10,20)
    local function noisewall(x1,y1,x2,y2)
        local noisecomponents = {"dirt","stone"}
        for y=y1, y2 do 
            for x=x1, x2 do 
                room:set(x,y,noisecomponents[math.random(1,2)])
            end
        end
    end

    noisewall(1,1,10,2)
    noisewall(1,1,2,20)
    noisewall(9,1,10,20)
    return room
end

function debug()
    local world = g2d.new(10,100)
    world:set(2,1,"dirt")
    world:set(1,1,"dirt")
    world:set(5,3,"stone")
    return world
end

function gen.world()
 local levels = {basicPlatforms,noise,debug}
 return levels[1]()
end

return gen
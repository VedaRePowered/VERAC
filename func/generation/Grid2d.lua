--possible todo, add infinite length
local g2d = {}

function g2d.new(w,h)
    local rows = {}
    for l=1, h do 
        rows[l] = {}
    end
    return setmetatable({
        tiles=rows,
        width=w,
        height=h,
	}, {__index=g2d})
end

function g2d:set(x,y,newValue)
    self.tiles[y][x] = newValue
end

function g2d:get(x,y)
    return self.tiles[y][x]
end

function g2d:getSize()
    local size = {x=5}
    if self.w then size.x=self.w end
    if self.h then size.x=self.h end
    print("size gotten")
    return size
end

--todo
function g2d:fill(x1,y1,x2,y2,newValue)

end

function g2d:merge(x,y,mergeGrid)

end



return g2d
Repeller = {}
Repeller.__index = Repeller

function Repeller:create(x,y)
    local repeller  = {}
    setmetatable(repeller, Repeller)
    
    repeller.location = Vector:create(x, y)
    repeller.r = 40
    repeller.strength = 10
    return repeller
end

function Repeller:update()

end

function Repeller:repel(particle)
    local dir = self.location - particle.location
    local d = dir:mag()
    if d <= self.r then
        d = 1
    end
    local dir = dir:norm()
    local force = -1 * self.strength / (d * d)
    dir:mul(force)
    return dir
end

function Repeller: draw()
    love.graphics.circle("line", self.location.x, self.location.y, self.r)
end

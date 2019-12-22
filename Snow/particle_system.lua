ParticleSystem = {}
ParticleSystem.__index = ParticleSystem

function ParticleSystem:create(x,y, n)
    local system = {}
    setmetatable(system, ParticleSystem)
    system.origin = Vector:create(x, y)
    system.n = n or 10
    system.particles = {}
    system.index = 0
    return system
end

function ParticleSystem:draw()
    r, g, b, a = love.graphics.getColor()
    love.graphics.circle("line", self.origin.x, self.origin.y, 20)
    for k, v in pairs(self.particles) do
        v:draw()
    end
    love.graphics.setColor(r, g, b, a)
end

function ParticleSystem:update()
    if #self.particles < self.n then
        self.particles[self.index] = Particle:create(self.origin.x, self.origin.y)
        self.index = self.index + 1
    end
    for k, v in pairs(self.particles) do
        if v:isDead() then
            v = Particle:create(self.origin.x, self.origin.y)
            self.particles[k] = v 
        end
        v:update()
    end
end

function ParticleSystem:applyForce(force)
    for k, v in pairs(self.particles) do
        v:applyForce(force)
    end
end

function ParticleSystem:applyRepeller(repeller)
    for k, v in pairs(self.particles) do
        local force = repeller:repel(v)
        v:applyForce(force)
    end
end
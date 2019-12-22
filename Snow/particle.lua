Particle = {}
Particle.__index = Particle


function Particle:create(x, y)
    local particle = {}
    setmetatable(particle, Particle)

    particle.location = Vector:create(x, y)
    particle.velocity = Vector:create(math.random(-200, 200) / 100, math.random(-200, 200) / 100)

    particle.acceleration = Vector:create(0, 0.05)
    particle.lifespan = 250
    particle.decay = math.random(3, 10) / 10
    return particle
end

function Particle:update()
    self.velocity:add(self.acceleration/10)
    self.location:add(self.velocity)
    self.acceleration:mul(0)
    self.lifespan = self.lifespan - self.decay
end

function Particle:applyForce(force)
    self.acceleration:add(force)
end

function Particle:isDead()
    return self.lifespan < 0
end

function Particle:draw()
    r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(1, 1, 1, self.lifespan / 100)
    -- love.graphics.circle("fill", self.location.x, self.location.y, 10)
    love.graphics.draw(textures.snow, self.location.x, self.location.y, 0.1, 0.1)
    love.graphics.setColor(r, g, b, a)
end
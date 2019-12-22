require("vector")
require("particle")
require("particle_system")
require("repeller")
function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    textures = {}
    textures.snow = love.graphics.newImage("snowflake.png")

    wind = Vector:create(0.05, 0)
    gravity = Vector:create(0, 0.3)
    system = ParticleSystem:create(width / 2, -150, 2000000,width)
    
end

function love.update()
    system.origin.x = math.random(0, 800)
    system:applyForce(wind)
    system:applyForce(gravity)
    system:update()
end

function love.draw()
    system:draw()
end



require('vector')
require('particle')
require('repeller')
require('particle_system')

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    textures = {}
    textures.heart = love.graphics.newImage('heart.png')
    textures.fusion = love.graphics.newImage('texture.png')
    system = ParticleSystem:create(width / 2, height / 2, 2000000)
    wind = Vector:create(0.1, 0)
    repeller = Repeller:create(width / 2 + 100, height / 2 + 150)
    gravity = Vector:create(0, -0.01)
    _Count = 0
    _Delta = 0
end

function love.draw()
    system:draw()
    --   repeller:draw()
end

function love.update(dt)
    _Count = _Count + 1
    if _Count >= 500 then
        _Delta = math.random(-3, 3)
        _Count = 0
        print("Wind was changed: " .. _Delta * 0.1)
    end

    if (_Delta ~= 0) then
        wind.x = 0.1
    end
    wind.x = wind.x * _Delta

    system:applyForce(wind)
    system:applyForce(gravity)
    system:applyRepeller(repeller)
    system:update()
end

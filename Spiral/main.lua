require("vector")
require("vehicle")
require("flow")

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    isShowMap = false

    vehicles = {}

    center = Vector:create(width / 2, height / 2)

    for i = 0, 20 do
      vehicles[i] = Vehicle:create(math.random(width), math.random(height))
      vehicles[i].velocity.x = 3
    end
    

    flow = FlowField:create(40)
    flow:init()
end

function love.update(dt)
  for i = 0, 20 do
    vehicles[i]:borders()
    vehicles[i]:follow(flow)
    vehicles[i]:update()
  end
end

function love.draw()
  for i = 0, 20 do
    vehicles[i]:draw()
  end

    flow:draw();

end
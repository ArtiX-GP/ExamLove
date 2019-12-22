FlowField = {}
FlowField.__index = FlowField

function FlowField:create(resolution)
    local flow = {}
    setmetatable(flow, FlowField)

    flow.field = {}
    flow.resolution = resolution
    love.math.setRandomSeed(10000)
    return flow
end

function FlowField:init()
    local rows = width / self.resolution
    local cols = height / self.resolution

    local dSafe = 500

    local a = 0.7

    for i = 0, rows do
        self.field[i] = {}
        for j = 0, cols do
            v = Vector:create(i * self.resolution, j * self.resolution) - center
            
            local r = math.sqrt(v.x * v.x + v.y * v.y) 
            local t = Vector:create(a * v.x - r * v.y, a * v.y + r * v.x)
            local tLen = math.sqrt(t.x * t.x + t.y * t.y)
            local k = dSafe / tLen;
            t:mul(k)
            v = v + t
            v:norm()
            v:mul(-1)

           self.field[i][j] = v
        end
    end
end

function FlowField:draw()
    r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(1 ,1 ,1 , 0.3)

    for i = 0, #self.field do -- # - это длина массива
        for j = 0, #self.field[i] do
            love.graphics.circle("fill", i * self.resolution,
                                j * self.resolution, 4)

            drawVector(self.field[i][j], i * self.resolution, j * self.resolution, self.resolution - 2)
        end
    end

    love.graphics.setColor(r, g, b, a)
end

function FlowField:lookup(v) -- возвращает объект (вектор) по которому сейчас ползем
    local col = math.floor(v.x / self.resolution)
    local row = math.floor(v.y / self.resolution)

    col = math.clamp(col, 0, #self.field)
    row = math.clamp(row, 0, #self.field[0])

    return self.field[col][row]:copy()
end

function drawVector(v, x, y, scale)
    love.graphics.push() -- временный перенос координат

    love.graphics.translate(x, y)
    love.graphics.rotate(v:heading())
    local len = v:mag() * scale
    
    love.graphics.line(0, 0, len, 0)

    love.graphics.pop() -- возвращаем координаты
end
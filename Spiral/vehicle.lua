Vehicle = {}
Vehicle.__index = Vehicle

function Vehicle:create(x, y)
    local veh = {}
    setmetatable(veh, Vehicle)
    veh.position = Vector:create(x, y)
    veh.velocity = Vector:create(0, 0)
    veh.acc = Vector:create(0, 0)
    veh.r = 10 -- размер
    veh.vertices = {
        0, -veh.r * 2,
        -veh.r, veh.r * 2,
        veh.r, veh.r * 2
    }

    veh.maxSpeed = 4
    veh.maxSteeringForce = 0.2

    veh.distance = 150
    veh.damping = 0.09

    veh.wtheta = 0
    return veh
end

function Vehicle:follow(flow) -- следует за потоком
    local desired = flow:lookup(self.position)
    desired:mul(self.maxSpeed)

    local steer = desired - self.velocity
    steer:limit(self.maxSteeringForce)
    self:applyForce(steer)
end

function Vehicle:update()
    self.velocity:add(self.acc)
    self.velocity:limit(self.maxSpeed)
    --self.velocity:mul(1 - self.damping)
    self.position:add(self.velocity)
    self.acc:mul(0)
end

function Vehicle:applyForce(force)
    self.acc:add(force)
end

-- Преследует.
function Vehicle:seek(target)
    local desired = self.position - target -- разница
    local mag = desired:mag()
    desired:norm()
    if mag < 100 then
        local m = math.map(mag, 0, 100, 0, self.maxSpeed)
        desired:mul(m)
    else
        desired:mul(self.maxSpeed)
    end

    local steer = self.velocity - desired
    steer:limit(self.maxSteeringForce)
    self:applyForce(steer)
end

-- Убегает.
function Vehicle:flee(target)
    local desired = target - self.position
    local mag = desired:mag()

    local steer = Vector:create(0,0)

    if (mag < self.distance) then

        steer = desired - self.velocity

        steer.x = -1 * steer.x
        steer.y = -1 * steer.y

        if mag < (self.distance / 3.5) then
            desired:mul(self.maxSpeed)
        else
            local m = mag / self.distance
            desired:mul(m)
        end
    end
    
    steer:limit(self.maxSteeringForce)
    self:applyForce(steer)
end

-- Блуждание.
function Vehicle:wander()
    local rwander = 25 -- радиус области видимости
    local dwander = 80 -- дальность видимости
    self.wtheta = self.wtheta + love.math.random(-30, 30) / 100 -- случайное рысканье (немного влево, немного вправо).
    local pos = self.velocity:copy()
    pos:norm()
    pos:mul(dwander)
    pos:add(self.position)

    local angle = self.velocity:heading()

    local offset = Vector:create(rwander * math.cos(self.wtheta + angle),
                                 rwander * math.sin(self.wtheta + angle)) -- в полярных координатах
    
    local target = pos + offset
    self:seek(target)

    love.graphics.circle("line", pos.x, pos.y, rwander)
    love.graphics.circle("fill", target.x, target.y, 4)
end

function Vehicle:borders()
    if (self.position.x  < -self.r) then
        self.position.x = width + self.r
    end

    if (self.position.y < -self.r) then
        self.position.y = height + self.r
    end

    if (self.position.x > width + self.r) then
        self.position.x = -self.r
    end

    if (self.position.y > height + self.r) then
        self.position.y = -self.r
    end
end

function Vehicle:boundaries()
    local desired = nil

    if (self.position.x < d) then
        desired = Vector:create(self.maxSpeed, self.velocity.y)
    elseif self.position.x > width - d then
        desired = Vector:create(-self.maxSpeed, self.velocity.y)
    end

    if (self.position.y < d) then
        desired = Vector:create(self.velocity.x, self.maxSpeed)
    elseif self.position.y > height - d then
        desired = Vector:create(self.velocity.x, -self.maxSpeed)
    end

    if desired then 
        desired:norm()
        desired:mul(self.maxSpeed)
        local steer = desired - self.velocity
        steer:limit(self.maxSteeringForce)
        self:applyForce(steer)
    end

end

function Vehicle:draw()
    local theta = self.velocity:heading()
    theta = theta + (90.0 * math.pi / 180.0)
    love.graphics.push()

    love.graphics.translate(self.position.x, self.position.y)
    love.graphics.rotate(theta)
    love.graphics.polygon("fill", self.vertices)

    love.graphics.pop()
end
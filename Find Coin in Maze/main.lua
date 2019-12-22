require "world"
require "player"
require "pqueue"
require "maze"

function loadTextures()
    env = {}
    env.tileset = love.graphics.newImage("assets/RogueEnvironment16x16.png")

    local quads = {
        {0,  5*16,  0*16}, -- floor v1
        {1,  6*16,  0*16}, -- floor v2
        {2,  7*16,  0*16}, -- floor v3
        {3,  0*16,  0*16}, -- upper left corner
        {4,  3*16,  0*16}, -- upper right corner
        {5,  0*16,  3*16}, -- lower left corner
        {6,  3*16,  3*16}, -- lower right corner
        {7,  2*16,  0*16}, -- horizontal
        {8,  0*16,  2*16}, -- vertical
        {9,  1*16,  2*16}, -- up
        {10, 2*16,  3*16}, -- down
        {11, 2*16,  1*16}, -- left
        {12, 1*16,  1*16}, -- right
        {13, 2*16,  2*16}, -- down cross
        {14, 1*16,  3*16}, -- up cross
        {15, 3*16,  1*16}, -- left cross
        {16, 0*16,  1*16}, -- right cross
        {17, 3*16, 14*16}, -- spikes
        {18, 5*16, 13*16} -- coin
    }
    env.textures = {}
    for i = 1, #quads do
        local q = quads[i]
        env.textures[q[1]] = love.graphics.newQuad(q[2], q[3], 16, 16, env.tileset:getDimensions())
    end

    pl = {}
    pl.tileset = love.graphics.newImage("assets/RoguePlayer_48x48.png")
    pl.textures = {}
    for i = 1, 6 do
        pl.textures[i] = love.graphics.newQuad((i - 1) * 48, 48 * 2, 48, 48, pl.tileset:getDimensions())
    end

end

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    loadTextures()

    world = World:create()
    scaleX = width / (world.width * 16)
    scaleY = height / (world.height * 16)

    _Map = {}
    for i = 0, 30 do
        _Map[i] = {}
        for j = 0, 30 do
            _Map[i][j] = "."
        end
    end

    _PlayerPath = nil
    _PlayerPathIdx = 0

    world:placeObjects()
    player = world.player
    -- Первичный ход - размещение игрока на карте.
    onMoveEnded()
end

function printMap(playerX, playerY)
    print()
    -- Вывод номеров колонок
    for i = -1, 30 do
        if (i == -1) then
            io.write("  ")
        else
            io.write(string.format("%02d ", i))
        end
    end

    print()
    for i = 0, 30 do
        for j = -1, 30 do
            if (j == -1) then
                -- Вывод номеров строк
                io.write(string.format("%02d ", i))
            else
                if (j == playerX) and (i == playerY) then
                    io.write(string.format("%-03s", "me"))
                else
                    io.write(string.format("%-03s", _Map[i][j]))
                end
            end
        end
        print()
    end

    -- Вывод номеров колонок
    for i = -1, 30 do
        if (i == -1) then
            io.write("  ")
        else
            io.write(string.format("%02d ", i))
        end
    end
    print()
end

function love.update(dt)
    player:update(dt, world)
    world:update(player)
end

function seek(env)
    print(env.position[1], env.position[2], env.left, env.right, env.up, env.down, env.coin)
    local directions = {}
    if not env.left then
        table.insert(directions, "left")
    end
    if not env.right then
        table.insert(directions, "right")
    end
    if not env.up then
        table.insert(directions, "up")
    end
    if not env.down then
        table.insert(directions, "down")
    end
    world:move(directions[love.math.random(1, #directions)])
end

function love.draw()
    love.graphics.scale(scaleX, scaleY)
    world:draw()
    player:draw(world)
end

-- Возвращает координаты ближайшего нуля, либо nil, если нуля нет
function getZero(playerX, playerY)
    -- Индексы всех нулей.
    local idxs = {}

    local playerPos = {}
    playerPos[1] = playerX
    playerPos[2] = playerY

    for i = 0, 30 do
        for j = 0, 30 do
            if (_Map[i][j] == "0") then
                table.insert(idxs, world:localToIndex(j, i))
            end
        end
    end

    if (#idxs > 0) then
        local minDif = 9999
        local idx = -1
        for i = 1, #idxs do
            local x, y = world:indexToLocal(idxs[i])
            -- Ближайший ноль к игроку.
            -- local mag = math.sqrt(math.pow((playerX - x), 2) + math.pow((playerY - y), 2))
            local zeroPos = {}
            zeroPos[1] = x
            zeroPos[2] = y
            local path = getPath(playerPos, zeroPos)
            if (#path < minDif) then
                minDif = #path
                idx = i
            end
        end

        local x, y = world:indexToLocal(idxs[idx])

        local res = {}
        res[1] = x
        res[2] = y
        return res
    end

    return nil
end

-- Пометка на карте текущей позиции
function check(env)
    -- local env = world:getEnv();
    local lx = env.position[1]
    local ly = env.position[2]

    if env.left then
        _Map[ly][lx - 1] = "N"
    else
        if not (_Map[ly][lx - 1] == "1") then
            _Map[ly][lx - 1] = "0"
        end
    end

    if env.right then
        _Map[ly][lx + 1] = "N"
    else
        if not (_Map[ly][lx + 1] == "1") then
            _Map[ly][lx + 1] = "0"
        end
    end

    if env.up then
        _Map[ly - 1][lx] = "N"
    else
        if not (_Map[ly - 1][lx] == "1") then
            _Map[ly - 1][lx] = "0"
        end
    end

    if env.down then
        _Map[ly + 1][lx] = "N"
    else
        if not (_Map[ly + 1][lx] == "1") then
            _Map[ly + 1][lx] = "0"
        end
    end


    _Map[ly][lx] = "1"
end

-- Callback движения игрока.
-- Вызывается, когда движение было завершено и игрок на нужной позиции.
function onMoveEnded()
    local env = world:getEnv();
    check(env)
    if (_PlayerPath) and (not getZero(env.position[1], env.position[2])) then
        print("Coin can't be founded!")
        printMap(env.position[1], env.position[2])
        return
    end

    if (env.coin == "underfoot") then
        print("Coin has been founded!")
        printMap(env.position[1], env.position[2])
        return
    end

    --printMap(env.position[1], env.position[2])
    if (not _PlayerPath) or (#_PlayerPath <= 0) or (_PlayerPathIdx <= 0) then
        _PlayerPath = getPath(env.position, getZero(env.position[1], env.position[2]))
        _PlayerPathIdx = #_PlayerPath
    end

    player:setFollow(_PlayerPath[_PlayerPathIdx])
    _PlayerPathIdx = _PlayerPathIdx - 1
end

-- Соседи клетки с индексом n, но только по карте игрока.
function getNeighbours(n)
    local x, y = world:indexToLocal(n)
    local coords = {{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}}
    local neighbours = {}
    for i = 1, #coords do
        local coord = coords[i]
        if not (_Map[coord[2]][coord[1]] == "N" or _Map[coord[2]][coord[1]] == ".") then
            -- print("Neighboor on " .. coord[2] .. " " .. coord[1] .. " contain " .. _Map[coord[2]][coord[1]])
            table.insert(neighbours, world:localToIndex(coord[1], coord[2]))
        end
    end
    return neighbours
end

-- from и to уже должны быть в формате 0..31
function getPath(from, to)
    local idxFrom = world:localToIndex(from[1], from[2])
    local idxTo = world:localToIndex(to[1], to[2])

    local frontier = PQueue:create()
    frontier:put(0, idxFrom)

    local visited = {}
    visited[idxFrom] = -1

    -- Сколько путь стоит в у.е.
    local costs = {}
    -- прийти туда, где стоим - ничего не стоит.
    costs[idxFrom] = 0

    while frontier:size() > 0 do
        local priority, currentPoint = frontier:get()

        if (currentPoint == idxTo) then
            -- Пришли куда надо
            break
        end

        -- Поиск соседей в текущей точке
        -- Получаем список индексов клеточек.
        local nbs = getNeighbours(currentPoint)
        if #nbs > 0 then
            for i = 1, #nbs do
                local next = nbs[i]
                local nextX, nextY = world:indexToLocal(next)

                local cost = 10

                if (world:checkCoin(nextX, nextY)) or (map[nextX][nextY] == "0") then
                    cost = 0
                end

                local new_cost = costs[currentPoint] + cost
                if (costs[next] == nil) or (new_cost < costs[next]) then
                    costs[next] = new_cost
                    frontier:put(new_cost, next)
                    visited[next] = currentPoint
                end
            end
        end
    end

    -- Ищем путь по графу.
    local path = {}
    local current = idxTo
    while current ~= idxFrom do
        table.insert(path, current)
        current = visited[current]
    end
    return path
end

function love.keypressed(key)
    if key == "left" then
        world:move("left")
    end
    if key == "right" then
        world:move("right")
    end
    if key == "up" then
        world:move("up")
    end
    if key == "down" then
        world:move("down")
    end

end
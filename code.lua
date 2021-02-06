
local message = "Hello this is a message from the game"
local map = nil

-- local map = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

local pX = 3.0
local pY = 3.0
local pRot = 0

local mapWidth = 12
local mapHeight = 12
local fov = 0.6 -- 3.14159 / 2.0

local depth = 12.0
local speed = 5.0

local display = Display()
local screenWidth = display.x
local screenHeight = display.y

local chunkSz = 4

local frameBuff = {}
local frameWidth = math.floor(screenWidth / chunkSz)
local frameHeight = math.floor(screenHeight / chunkSz)

function InitMap()
    map = {}
    for i = 0, mapWidth - 1, 1 do
        for j = 0, mapHeight - 1, 1 do
            local cell = 0
            if i == 0 or j == 0 or i == mapWidth - 1 or j == mapHeight - 1 then
                cell = 1
            end
            map[i + j * mapHeight] = cell
        end
    end
end

function InitFrame()

    frameBuff = {}

    for j = 0, frameHeight, 1 do
        for i = 0, frameWidth, 1 do
            frameBuff[i + j * frameWidth] = 0
        end
    end
end

function DrawFrame()

    for j = 0, frameHeight - 1, 1 do
        for i = 0, frameWidth - 1, 1 do
            local tgt_x = (i) * chunkSz
            local tgt_y = (j) * chunkSz
            local shading = frameBuff[i + j * frameWidth]

            DrawRect(tgt_x, tgt_y, chunkSz, chunkSz, shading, DrawMode.Tile)

        end
    end

end

function randomObjective()
    local i = math.random(2, mapWidth - 2)
    local j = math.random(2, mapHeight - 2)

    map[i + j * mapHeight] = 2
end

function defineExit()
    local i = 0
    local j = 8

    map[i + j * mapHeight] = 3
end

--[[
  The Init() method is part of the game's lifecycle and called a game starts.
  We are going to use this method to configure background color,
  ScreenBufferChip and draw a text box.
]]--
function Init()
    -- Here we are manually changing the background color
    BackgroundColor(0)
    InitMap()

    randomObjective()
    defineExit()
end

--[[
  The Update() method is part of the game's life cycle. The engine calls
  Update() on every frame before the Draw() method. It accepts one argument,
  timeDelta, which is the difference in milliseconds since the last frame.
]]--

function calculateDisplacement(amount)

    -- we have cases in four quadrants to find the displacement along the line
    -- the user presses the forward key but this does not translate to a pure X movement

    if pRot >= 0 and pRot <= 1.57 then

        xDisplace = math.sin(pRot) * amount
        yDisplace = amount - xDisplace

        state = map[math.floor(pX + xDisplace) + math.floor(pY + yDisplace) * mapWidth]
        if (state ~= 1) then
          if state == 2 then
            map[math.floor(pX + xDisplace) + math.floor(pY + yDisplace) * mapWidth] = 0
            exitHidden = false
          end
          pY = pY + yDisplace
          pX = pX + xDisplace
        end

    elseif pRot >= 1.57 and pRot <= 3.14 then

        local realRot = pRot - 1.57
        yDisplace = math.sin(realRot) * amount
        xDisplace = (amount - yDisplace)

        state = map[math.floor(pX + xDisplace) + math.floor(pY - yDisplace) * mapWidth]
        if (state ~= 1) then
          if state == 2 then
            map[math.floor(pX + xDisplace) + math.floor(pY - yDisplace) * mapWidth] = 0
            exitHidden = false
          end
          pY = pY - yDisplace
          pX = pX + xDisplace
        end

    elseif pRot >= 3.14 and pRot < 4.71 then

        local realRot = pRot - (2 * 1.57)
        xDisplace = math.sin(realRot) * amount
        yDisplace = amount - xDisplace

        state = map[math.floor(pX - xDisplace) + math.floor(pY - yDisplace) * mapWidth]
        if (state ~= 1) then
          if state == 2 then
            map[math.floor(pX - xDisplace) + math.floor(pY - yDisplace) * mapWidth] = 0
            exitHidden = false
          end
          pY = pY - yDisplace
          pX = pX - xDisplace
        end

    else

        local realRot = pRot - (2 * 1.57)
        yDisplace = math.sin(realRot) * amount
        xDisplace = amount - yDisplace

        state = map[math.floor((pX - xDisplace) + (pY + yDisplace) * mapWidth)]
        if (state ~= 1) then
          if state == 2 then
            map[math.floor((pX - xDisplace) + (pY + yDisplace) * mapWidth)] = 0
            exitHidden = false
          end
          pY = pY + yDisplace
          pX = pX - xDisplace
        end
    end
end

local exitHidden = true
local doUpdate = 1
function Update(timeDelta)
    DrawText("pX: " .. tostring(round(pX, 1)), 0, 0, DrawMode.Tile, "large", 15)
    DrawText("pY: " .. tostring(round(pY, 1)), 0, 1, DrawMode.Tile, "large", 15)
    DrawText("pR: " .. tostring(round(pRot, 1)), 0, 2, DrawMode.Tile, "large", 15)
    DrawText("fov: " .. tostring(round(fov, 1)), 0, 3, DrawMode.Tile, "large", 15)

    doUpdate = 0

    if Key(Keys.W) then
        calculateDisplacement(0.1)
        doUpdate = 1
    end

    if Key(Keys.S) then
        calculateDisplacement(-0.1)
        doUpdate = 1
    end

    if Key(Keys.A) then
        pRot = round(pRot - 0.1, 1)
        if pRot < 0 then
            pRot = 6.23
        end
        doUpdate = 1
    end

    if Key(Keys.D) then
        pRot = round(pRot + 0.1, 1)
        if pRot > 6.23 then
            pRot = 0
        end
        doUpdate = 1
    end

    if Key(Keys.R) then
        fov = fov + 0.1
        doUpdate = 1
    end

    if Key(Keys.T) then
        fov = fov - 0.1
        doUpdate = 1
    end

    if doUpdate == 0 then
        return
    end

    -- We can use the RedrawDisplay() method to clear the screen and redraw
    -- the tilemap in a single call.
    RedrawDisplay()
    InitFrame()

    for i = 0, display.x, chunkSz do
        local rayAngle = (pRot - fov / 2.0) + (i / display.x) * fov
        local distance = 0.0

        local collide = 0

        local objective = false
        local exit = false

        local eyeX = math.sin(rayAngle)
        local eyeY = math.cos(rayAngle)

        while collide ~= 1 and distance < depth do

            distance = distance + 0.5

            local test_col = math.floor(pX + eyeX * distance + 0.5)
            local test_row = math.floor(pY + eyeY * distance + 0.5)

            if test_col < 0 or test_col >= mapWidth or test_row < 0 or test_row >= mapHeight then
                collide = 1
                distance = depth
            else
                local var = map[((test_col) * mapWidth + test_row)]
                if var == 1 then
                    collide = 1
                elseif var == 2 then
                    collide = 1
                    objective = true
                elseif var == 3 then
                    collide = 1
                    exit = true
                end
            end
        end

        local ceiling = (display.y / 2.0) - (display.y / distance)
        local floor = display.y - ceiling

        local shading = 1
        shading = 10 - math.floor(distance + 0.5)
        if shading < 1 then
            shading = 1
        end

        if objective then
            shading = 13
            if distance < 10 then
                shading = 12
            elseif distance < 5 then
                shading = 11
            end
        elseif exit and not exitHidden then
            shading = 15
        end

        -- if distance <= depth / 6.0 then
        --   shading = 6
        -- elseif distance <= depth / 5.0 then
        --   shading = 5
        -- elseif distance <= depth / 4.0 then
        --   shading = 4
        -- elseif distance <= depth / 3.0 then
        --   shading = 3
        -- elseif distance <= depth / 2.0 then
        --   shading = 2
        -- elseif distance <= depth / 1.0 then
        --   shading = 1
        -- elseif distance <= depth / 1.0 then
        --   shading = 1
        -- elseif distance <= depth / 1.0 then
        --   shading = 1
        -- elseif distance <= depth / 1.0 then
        --   shading = 1
        -- elseif distance <= depth / 1.0 then
        --   shading = 1
        -- end

        for j = 0, display.y, chunkSz do

            if j <= ceiling then
                -- DrawText( ",", j, i, DrawMode.Tile, "small", shading)

            elseif j > ceiling and j <= floor then
                local tgt_x = math.floor(i / chunkSz)
                local tgt_y = math.floor(j / chunkSz)

                -- put everytihng into a buffered frame so we dont draw over chunks
                -- squeeze every last bit of perf out of the drawing logic
                if frameBuff[tgt_x + tgt_y * frameWidth] < shading then
                    frameBuff[tgt_x + tgt_y * frameWidth] = shading
                end

            else
                local shade = "a"
                local b = 1.0 - ((j - screenHeight / 2.0) / (screenHeight / 2.0));

                if math.fmod(i, 5) == 0 and math.fmod(j, 5) == 0 then
                    if b < 0.25 then
                        shade = "#";
                    elseif b < 0.5 then
                        shade = "x";
                    elseif b < 0.75 then
                        shade = ".";
                    elseif b < 0.9 then
                        shade = "-";
                    else
                        shade = " ";
                    end

                    -- DrawText(shade, i, j, DrawMode.UI, "small", 2)
                end
            end
        end
    end
    DrawFrame()
end

--[[
  The Draw() method is part of the game's life cycle. It is called after
  Update() and is where all of our draw calls should go. We'll be using this
  to render sprites to the display.
]]--
function Draw()

end

-- draw a traingle
function DrawTriangle(pointA, pointB, top, color)
    aX, aY, bX, bY = pointA[1], pointA[2], pointB[1], pointB[2]

    if aX > bX then
        tempX, tempY = aX, aY
        aX, aY = bX, bY
        bX, bY = tempX, tempY
    end

    m = bY - aY / bX - aX
    b = aY - (m * aX)

    for x = aX, bX do
        y = equationOfALine(x, m, b)
        if top then
            DrawRect(x, math.min(aY, bY), 1, math.abs(math.min(aY, bY) - y), color)
        else
            DrawRect(x, y, 1, math.abs(y - aY), color)
        end
    end
end

-- return a y given an m and b for a given x
function equationOfALine(x, m, b)
    local returnY = (m * x) + b
    return round(returnY)
end

-- round
function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

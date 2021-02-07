
local message = "Hello this is a message from the game"
local map = nil

-- local map = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

local pX = 3.0
local pY = 3.0
local pRot = 0

local mapWidth = 12
local mapHeight = 12
local fov = 1 -- 3.14159 / 2.0

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

function InitMap2()
  map = {}
  for i = 0, mapWidth - 1, 1 do
      for j = 0, mapHeight - 1, 1 do
          local cell = 0
          if i == 0 or j == 0 or i == mapWidth - 1 or j == mapHeight - 1 then
              cell = 1
          end

          if i >= 7 and j <= 5 then
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

local objective = {}
local objective2 = {}
local exitHidden = true

function randomObjective(obj, value)
    local i = math.random(4, mapWidth - 3)
    local j = math.random(4, mapHeight - 3)

    obj[1] = i
    obj[2] = j

    map[i + j * mapHeight] = value

    map[(i-1) + (j-1) * mapHeight] = value + 1
    map[i + (j-1) * mapHeight] = value + 1
    map[(i+1) + (j-1) * mapHeight] = value + 1
    map[(i-1) + j * mapHeight] = value + 1
    map[(i+1) + j * mapHeight] = value + 1
    map[(i-1) + (j+1) * mapHeight] = value + 1
    map[i + (j+1) * mapHeight] = value + 1
    map[(i+1) + (j+1) * mapHeight] = value + 1
end

function defineExit()
    local i = 0
    local j = 8

    map[i + j * mapHeight] = 3

    map[1 + 7 * mapHeight] = 4
    map[1 + 8 * mapHeight] = 4
    map[1 + 9 * mapHeight] = 4

    exitHidden = true
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

    randomObjective(objective, 5)
    defineExit()
end

--[[
  The Update() method is part of the game's life cycle. The engine calls
  Update() on every frame before the Draw() method. It accepts one argument,
  timeDelta, which is the difference in milliseconds since the last frame.
]]--

local text = "Find the objective!"
function calculateDisplacement(amount)

    -- we have cases in four quadrants to find the displacement along the line
    -- the user presses the forward key but this does not translate to a pure X movement

    if pRot >= 0 and pRot <= 1.57 then

        xDisplace = math.sin(pRot) * amount
        yDisplace = amount - xDisplace

        x = math.floor(pX + xDisplace + 0.5)
        y = math.floor(pY + yDisplace + 0.5)

        value = map[y + x * mapWidth]
        if (value ~= 1) then
          checkSpace(value, x, y)

          pY = pY + yDisplace
          pX = pX + xDisplace
        end

    elseif pRot >= 1.57 and pRot <= 3.14 then

        local realRot = pRot - 1.57
        yDisplace = math.sin(realRot) * amount
        xDisplace = (amount - yDisplace)

        x = math.floor(pX + xDisplace + 0.5)
        y = math.floor(pY - yDisplace + 0.5)

        value = map[y + x * mapWidth]
        if (value ~= 1) then
          checkSpace(value, x, y)

          pY = pY - yDisplace
          pX = pX + xDisplace
        end

    elseif pRot >= 3.14 and pRot < 4.71 then

        local realRot = pRot - (2 * 1.57)
        xDisplace = math.sin(realRot) * amount
        yDisplace = amount - xDisplace

        x = math.floor(pX - xDisplace + 0.5)
        y = math.floor(pY + yDisplace + 0.5)

        value = map[y + x * mapWidth]
        if (value ~= 1) then
          checkSpace(value, x, y)

          pY = pY - yDisplace
          pX = pX - xDisplace
        end

    else

        local realRot = pRot - (2 * 1.57)
        yDisplace = math.sin(realRot) * amount
        xDisplace = amount - yDisplace

        x = math.floor(pX - xDisplace + 0.5)
        y = math.floor(pY - yDisplace + 0.5)

        value = map[y + x * mapWidth]
        if (value ~= 1) then
          checkSpace(value, x, y)

          pY = pY + yDisplace
          pX = pX - xDisplace
        end
    end
end

local level = 1
function checkSpace(value, x, y)
    if (value >= 5) then
      map[objective[1] + objective[2] * mapWidth] = 0
      exitHidden = false
      text = "Find the exit!"
    elseif (map[y + x * mapWidth] >= 3) then
      if level == 2 then
        InitMap2()
        -- randomly place the player in the room
        pX = 3
        pY = 3
        pRot = 0
      else
        InitMap()
        -- randomly place the player in the room
        pX = math.random(3, mapWidth - 2)
        pY = math.random(3, mapWidth - 2)
        pRot = math.random(0, 4)
      end

      text = "Find the objective"
      randomObjective(objective, 5)

      if level > 2 then
        text = text .. "s!"
        randomObjective(objective2, 7)
      end


      defineExit()
      level = level + 1
    end
end

local doUpdate = 1
local lastWPressTime = 0
local lastAPressTime = 0
local lastSPressTime = 0
local lastDPressTime = 0
local delay = 0.05

function Update(timeDelta)

    doUpdate = 0
    local currentTime = os.clock()

    if Key(Keys.W) and (currentTime - lastWPressTime) > delay then
        calculateDisplacement(0.1)
        doUpdate = 1
        lastWPressTime = currentTime
    end

    if Key(Keys.A) and (currentTime - lastAPressTime) > delay then
        pRot = pRot - 0.05
        if pRot < 0 then
            pRot = 6.23
        end
        doUpdate = 1
        lastAPressTime = currentTime
    end

    if Key(Keys.S) and (currentTime - lastSPressTime) > delay then
        calculateDisplacement(-0.1)
        doUpdate = 1
        lastSPressTime = currentTime
    end

    if Key(Keys.D) and (currentTime - lastDPressTime) > delay then
        pRot = pRot + 0.05
        if pRot > 6.23 then
            pRot = 0
        end
        doUpdate = 1
        lastDPressTime = currentTime
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
                elseif var == 5 then
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

                    DrawText(shade, i, j, DrawMode.UI, "small", 2)
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
  DrawText("Level " .. tostring(level) .. ": " .. text, 0, 0, DrawMode.UI, "large", 14)

  DrawText("x:" .. tostring(math.floor(pX + 0.5)) .. " y:" .. tostring(math.floor(pY + 0.5)), 0, 10, DrawMode.UI, "large", 14)
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

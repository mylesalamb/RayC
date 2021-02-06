--[[
  Pixel Vision 8 - New Template Script
  Copyright (C) 2017, Pixel Vision 8 (@pixelvision8)
  Created by Jesse Freeman (@jessefreeman)

  This project was designed to display some basic instructions when you create
  a new game.  Simply delete the following code and implement your own Init(),
  Update() and Draw() logic.

  Learn more about making Pixel Vision 8 games at
  https://www.pixelvision8.com/getting-started
]] --
--[[
  This this is an empty game, we will the following text. We combined two sets
  of fonts into the default.font.png. Use uppercase for larger characters and
  lowercase for a smaller one.
]] --

local message = "Hello this is a message from the game"
local map = nil



-- local map = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

local pX = 3.0
local pY = 3.0
local pRot = 0

local mapWidth = 18
local mapHeight = 18
local fov = 0.6 --3.14159 / 2.0

local depth = 18.0
local speed = 5.0

local display = Display()

local chunkSz = 4

function InitMap()
  map = {}
  for i=0, mapWidth - 1, 1 do
    for j=0, mapHeight - 1, 1 do
      local cell = 0
      if i == 0 or j == 0 or i == mapWidth - 1 or j == mapHeight - 1 then
        cell = 1
      end
      map[i + j * mapHeight] = cell
    end
  end
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

    local display = Display()
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

        pY = pY + yDisplace
        pX = pX + xDisplace

    elseif pRot >= 1.57 and pRot <= 3.14  then
        local realRot = pRot
        yDisplace = math.sin(realRot) * amount
        xDisplace = (amount - yDisplace)

        pY = pY - yDisplace
        pX = pX + xDisplace



    elseif pRot >= 3.14 and pRot < 4.71 then
        local realRot = pRot - (2 * 1.57)
        xDisplace = math.sin(realRot) * amount
        yDisplace = amount - xDisplace

        pY = pY - yDisplace
        pX = pX - xDisplace
    else
        local realRot = pRot - (2 * 1.57)
        yDisplace = math.sin(realRot) * amount
        xDisplace = amount - yDisplace

        pY = pY + yDisplace
        pX = pX - xDisplace
    end


end

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

for i = 0, display.x, chunkSz do
    local rayAngle = (pRot - fov / 2.0) + (i / display.x) * fov
    local distance = 0.0

    local collide = 0

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
            if map[ ((test_col) * mapWidth + test_row)] == 1 then
                collide = 1
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
          DrawRect( i, j, chunkSz, chunkSz, shading, DrawMode.Tile )

        else
            local shade = "a"
            local b = 1.0 - ((j - display.y / 2.0) / (display.y / 2.0));

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

            --  DrawText( "-", j, i, DrawMode.Tile, "small", shading)

        end
    end
end


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
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

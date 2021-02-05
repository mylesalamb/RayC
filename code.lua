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
local map = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
             1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
             1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
             1, 0, 0, 0, 1, 1, 1, 0, 0, 1,
             1, 0, 0, 0, 1, 1, 1, 0, 0, 1,
             1, 0, 0, 0, 1, 1, 1, 0, 0, 1,
             1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
             1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 
             1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 
             1, 1, 1, 1, 1, 1, 1, 1, 1, 1}

local pX = 1.0
local pY = 1.0
local pRot = 5.0

local mapWidth = 10
local mapHeight = 10
local fov = 3.14159 / 2.0

local depth = 15.0
local speed = 5.0

local screenWidth = 256
local screenHeight = 256

--[[
  The Init() method is part of the game's lifecycle and called a game starts.
  We are going to use this method to configure background color,
  ScreenBufferChip and draw a text box.
]]--
function Init()
    -- Here we are manually changing the background color
    BackgroundColor(0)

    local display = Display()
end

--[[
  The Update() method is part of the game's life cycle. The engine calls
  Update() on every frame before the Draw() method. It accepts one argument,
  timeDelta, which is the difference in milliseconds since the last frame.
]]--

function Update(timeDelta)
  DrawTriangle({100, 50}, {50, 100}, true, 1)
end

--[[
  The Draw() method is part of the game's life cycle. It is called after
  Update() and is where all of our draw calls should go. We'll be using this
  to render sprites to the display.
]]--
function Draw()

    -- We can use the RedrawDisplay() method to clear the screen and redraw
    -- the tilemap in a single call.
    RedrawDisplay()
    
    for i = 1, screenWidth, 1 do
        local rayAngle = (pRot - fov / 2.0) + (i / screenWidth) * fov
        local distance = 0.0

        local collide = 0

        local eyeX = math.sin(rayAngle)
        local eyeY = math.cos(rayAngle)

        while collide ~= 1 and distance < depth do
          

            distance = distance + 0.5

            local test_col = pX + eyeX * distance
            local test_row = pY + eyeY * distance

            if test_col < 0 or test_col >= mapWidth or test_row < 0 or test_row >= mapHeight then
                collide = 1
                distance = depth
            else
                if map[test_col * mapWidth + test_row] == 1 then
                    collide = 1
                end
            end
            
        end

        local ceiling = (screenHeight / 2.0) - (screenHeight / distance)
        local floor = screenHeight - ceiling

        local shading = 1
        if distance <= depth / 4.0 then
        shading = 1
        elseif distance <= depth / 3.0 then
        shading = 2
        elseif distance <= depth / 2.0 then
        shading = 3
        else
        shading = 4
        end

        for j = 1, screenHeight, 1 do
          
            if j <= ceiling then
              -- DrawText( ",", j, i, DrawMode.Tile, "small", shading)

            elseif j > ceiling and j <= floor then
              DrawRect( j, i, 5, 5, shading, DrawMode.Tile )

            else
                local shade = "a"
                local b = 1.0 - ((j - screenHeight / 2.0) / (screenHeight / 2.0));

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

                -- DrawText( "-", j, i, DrawMode.Tile, "small", shading)

            end
        end
    end
end


-- draw a traingle
function DrawTriangle(pointA, pointB, top, color)
  aX, aY, bX, bY = pointA[1], pointA[2], pointB[1], pointB[2]

  if aX > bX then
    local tempX, tempY = aX, aY
    aX, aY = bX, bY
    bX, bY = tempX, tempY
  end

  m = bY - aY / bX - aX
  b = aY - (m * aX)

  for x = aX, bX do
    y = equationOfALine(x, m, b)
    if top then
      DrawRect(x, min(aY, bY), 1, abs(min(aY, bY) - y), color)
    else
      DrawRect(x, y, 1, abs(y - aY), color)
    end
  end
end


-- find max
function min(a, b)
  if a < b then
    return a
  else
    return b
  end
end


-- absolute value
function abs(value)
  if value < 0 then
    return value * -1
  else
    return value
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

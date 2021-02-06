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

-- Vector Class
Vector = {}
Vector.__index = Vector

function Vector:create (x1, y1)
  local vec = {}
  setmetatable(vec, Vector)
  vec.i = x1
  vec.j = y1
  return vec
end

function Vector:add(v)
  return Vector:create(self.i + v.i, self.j + v.j)
end

function Vector:mul( v )
  return self.i * v.i + self.j * v.j
end

function Vector:tostring()
  return ("<%g, %g>"):format(self.i, self.j)
end

function Vector:magnitude()
  return math.sqrt( self * self )
end

function Vector:normalise()
  self.i = self.i / self:magnitude()
  self.j = self.j / self:magnitude()
end

function Vector:rotate(angle)
  local oldAngle = math.atan2(self.j, self.i)
  angle = angle + oldAngle

  local x = (self.i * math.cos(angle)) - (self.j * math.sin(angle))
  local y = (self.i * math.sin(angle)) + (self.j * math.cos(angle))
  self.i, self.j = x, y
end


-- Boundary Class
Boundary = {}
Boundary.__index = Boundary

function Boundary:create (x1, y1, x2, y2)
  local boundary = {}
  setmetatable(boundary, Boundary)
  boundary.a = Vector:create(x1, y1)
  boundary.b = Vector:create(x2, y2)
  return boundary
end


-- Ray Class
Ray = {}
Ray.__index = Ray

function Ray:create (x1, y1)
  local ray = {}
  setmetatable(ray, Ray)
  ray.pos = Vector:create(x1, y1)
  ray.dir = Vector:create(1, 0)
  return ray
end

function Ray:setDirection(x, y)
  self.dir.i = x - self.pos.i
  self.dir.j = y - self.pos.j
  self.dir:normalise()
end

function Ray:changeAngle(angle)
  self.dir:rotate(angle)
end

function Ray:getAngle(angle)
  return math.atan2(self.dir.j, self.dir.i)
end

function Ray:cast(wall)
  local x1, y1, x2, y2 = wall.a.i, wall.a.j, wall.b.i, wall.b.j
  local x3, y3 = self.pos.i, self.pos.j
  local point = self.pos:add(self.dir)
  local x4, y4 = point.i, point.j

  den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
  if den == 0 then
    return
  end

  t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
  u = -1 * (((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den)

  if (t > 0 and t < 1 and u > 0) then
    return true
  else
    return
  end
end


-- world map
local map = {
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
}


-- world representation as a list of vector Boundary
local world = {
  Boundary:create(0, 0, 0, 16),
  Boundary:create(0, 0, 16, 0),
  Boundary:create(0, 16, 16, 16),
  Boundary:create(16, 0, 16, 16),
}

-- local map = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

local pX = 5.0
local pY = 3.0
local pRot = 0

local mapWidth = 10
local mapHeight = 10
local fov = 3.14159 / 1.5

local depth = 18.0
local speed = 5.0

local screenWidth = 264
local screenHeight = 248

local chunkSz = 2

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
local ray = Ray:create(1, 1)
function Update(timeDelta)
  local pt = ""

  DrawText("pX: " .. tostring(round(pX, 1)), 0, 0, DrawMode.Tile, "large", 15)
  DrawText("pY: " .. tostring(round(pY, 1)), 0, 1, DrawMode.Tile, "large", 15)
  DrawText("pR: " .. tostring(round(pRot, 1)), 0, 2, DrawMode.Tile, "large", 15)

  for index = 1, 4 do
    local cast = ray:cast(world[index])

    if cast then
      pt = cast
    end

    DrawText("intersect wall " .. tostring(index) .. ": " .. tostring(pt), 0, 3 + index, DrawMode.Tile, "large", 15)
  end

  DrawText("ray angle: " .. tostring(ray:getAngle() * 180 / math.pi), 0, 9, DrawMode.Tile, "large", 15)
  ray:changeAngle(1 * math.pi / 180)

  doUpdate = 0

  if Key(Keys.W) then
    calculateDisplacement(0.5)
    doUpdate = 1
  end

  if Key(Keys.S) then
    calculateDisplacement(-0.5)
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

  -- reset to start
  if Key(Keys.R) then
    pX = 5.0
    pY = 3.0
    pRot = 0
    doUpdate = 1
  end


  if doUpdate == 0 then
    return
end

-- We can use the RedrawDisplay() method to clear the screen and redraw
-- the tilemap in a single call.
--
-- for i = 1, screenWidth, chunkSz do
--     local rayAngle = (pRot - fov / 2.0) + (i / screenWidth) * fov
--     local distance = 0.0
--
--     local collide = 0
--
--     local eyeX = math.sin(rayAngle)
--     local eyeY = math.cos(rayAngle)
--
--     while collide ~= 1 and distance < depth do
--
--
--         distance = distance + 0.5
--
--         local test_col = math.floor(pX + eyeX * distance)
--         local test_row = math.floor(pY + eyeY * distance)
--
--         if test_col < 0 or test_col >= mapWidth or test_row < 0 or test_row >= mapHeight then
--             collide = 1
--             distance = depth
--         else
--             if map[ (test_col - 1) * mapWidth + test_row] == 1 then
--                 collide = 1
--             end
--         end
--
--     end
--
--     local ceiling = (screenHeight / 2.0) - (screenHeight / distance)
--     local floor = screenHeight - ceiling
--
--     local shading = 1
--     if distance <= depth / 6.0 then
--       shading = 6
--     elseif distance <= depth / 5.0 then
--       shading = 5
--     elseif distance <= depth / 4.0 then
--       shading = 4
--     elseif distance <= depth / 3.0 then
--       shading = 3
--     elseif distance <= depth / 2.0 then
--       shading = 2
--     elseif distance <= depth / 1.0 then
--       shading = 1
--     end
--
--     for j = 1, screenHeight, chunkSz do
--
--         if j <= ceiling then
--           -- DrawText( ",", j, i, DrawMode.Tile, "small", shading)
--
--         elseif j > ceiling and j <= floor then
--           DrawRect( i, j, chunkSz, chunkSz, shading, DrawMode.Tile )
--
--         else
--             local shade = "a"
--             local b = 1.0 - ((j - screenHeight / 2.0) / (screenHeight / 2.0));
--
--             if b < 0.25 then
--                 shade = "#";
--             elseif b < 0.5 then
--                 shade = "x";
--             elseif b < 0.75 then
--                 shade = ".";
--             elseif b < 0.9 then
--                 shade = "-";
--             else
--                 shade = " ";
--             end
--
--             --  DrawText( "-", j, i, DrawMode.Tile, "small", shading)
--
--         end
--     end
-- end
--

end

--[[
  The Draw() method is part of the game's life cycle. It is called after
  Update() and is where all of our draw calls should go. We'll be using this
  to render sprites to the display.
]]--
function Draw()

  RedrawDisplay()

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

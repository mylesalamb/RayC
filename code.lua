--[[
  Pixel Vision 8 - New Template Script
  Copyright (C) 2017, Pixel Vision 8 (@pixelvision8)
  Created by Jesse Freeman (@jessefreeman)

  This project was designed to display some basic instructions when you create
  a new game.  Simply delete the following code and implement your own Init(),
  Update() and Draw() logic.

  Learn more about making Pixel Vision 8 games at
  https://www.pixelvision8.com/getting-started
]]--

--[[
  The Init() method is part of the game's lifecycle and called a game starts.
  We are going to use this method to configure background color,
  ScreenBufferChip and draw a text box.
]]--
function Init()
  BackgroundColor(0)
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

  -- TODO add your own draw logic here.

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
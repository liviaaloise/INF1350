
local function newblip (vel)
  local x, y = 0, 0
  local width, height = love.graphics.getDimensions( )
  
  local activity = true
  local inactiveTime = 0
  
  local wait = function (seg)
    activity = false
    inactiveTime = love.timer.getTime() + seg
    coroutine.yield()
  end
  
  local function up()
    while true do
--      x = x+vel
      x = x + 13 -- x agora nao eh mais incrementado por vel
      if x > width then
        -- volta para a esquerda da janela
        x = 0
      end
      -- coroutine.yield()
      wait(vel)
    end
  end
  return {
    update = coroutine.wrap(up),
    affected = function (pos)
      if pos > x and pos < x+10 then
      -- "pegou" o blip
        return true
      else
        return false
      end
    end,
    draw = function ()
      love.graphics.rectangle("line", x, y, 10, 10)
    end,
    
    setActivity = function (bool)
      activity = bool
    end,
    
--    getActivity = function () return activity end,
    getInactiveTime = function () return inactiveTime end
    
  }
end

local function newplayer ()
  local x, y = 0, 200
  local width, height = love.graphics.getDimensions( )
  return {
  try = function ()
    return x
  end,
  update = function (dt)
    x = x + 0.5
    if x > width then
      x = 0
    end
  end,
  draw = function ()
    love.graphics.rectangle("line", x, y, 30, 10)
  end
  }
end

function love.keypressed(key)
  if key == 'a' then
    pos = player.try()
    for i in ipairs(listabls) do
      local hit = listabls[i].affected(pos)
      if hit then
        table.remove(listabls, i) -- esse blip "morre" 
        return -- assumo que apenas um blip morre
      end
    end
  end
end

function love.load()
  player =  newplayer()
  listabls = {}
  for i = 1, 5 do
    listabls[i] = newblip(i)
  end
end

function love.draw()
  player.draw()
  for i = 1,#listabls do
    listabls[i].draw()
  end
end

function love.update(dt)
  
  nowTime = love.timer.getTime()

  player.update(dt)
  for i = 1,#listabls do
    if listabls[i].getInactiveTime() <= nowTime then
--      listabls[i].setActivity(true)
      listabls[i].update()
    end
--    if listabls[i].getActivity() == true then
--      listabls[i].update()
--    end
--    print(i, listabls[i].getActivity(), listabls[i].getInactiveTime(), nowTime)
    print(i, listabls[i].getInactiveTime(), nowTime)
  end
  print("\n")
end
  

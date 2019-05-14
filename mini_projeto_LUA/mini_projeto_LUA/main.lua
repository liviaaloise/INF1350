--                                                                               Blip
local function newblip (vel, posx)
  local x, y = posx, 0
  local width, height = love.graphics.getDimensions( )
  local inactiveTime = 0
  
  local wait = function (seg)
    activity = false
    inactiveTime = love.timer.getTime() + seg
    coroutine.yield()
  end
  
  local function up()
    while true do
      x = x + 15 -- x agora nao eh mais incrementado por vel
      if x > width then
        -- volta para a esquerda da janela
        x = 0
      end
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
    
    getInactiveTime = function () return inactiveTime end
  }
end



--                                                                               Player
local function newplayer ()
  local x = 0
  local y = 200
  local width, height = love.graphics.getDimensions( )
  
  return {
    try = function ()
      return x
    end,
    
    update = function (dt)
      x = x + 1.5
      if x > width then
        x = 0
      end
    end,
    
    getX = function ()
      return x
    end,
    getY = function ()
      return y
    end,
    
    setFireStatus = function (bool) fire_status = bool end,
    getFireStatus = function () return fire_status end,
    getWaitTime = function () return bullet_wait end,
    
    draw = function ()
--      love.graphics.polygon("fill", x, y, x+10, y, x, y-10)
      love.graphics.rectangle("fill", x, y, 35, 10)
    end
  }
end




--                                                                               Bullet
local function newbullet (player)
  local sx = player.getX() + 35/2
  local sy = player.getY()
  local fire_status = false
  local bullet_wait = 0
  local width, height = love.graphics.getDimensions( )
  
  local wait = function (seg)
    bullet_wait = love.timer.getTime() + seg
    coroutine.yield()
  end
  
  local function up()
    while true do
      if fire_status then
        sy = sy - 3.0
      end
      if sy < 0 then 
        fire_status = false
      end
      wait(0.0001)
    end
  end
  return {
    update = coroutine.wrap(up),
--    update = up,
    getSX = function () return sx end,
    getSY = function () return sy end,
    setSX = function (x) sx = x end,
    setSY = function (y) sy = y end,
    setFireStatus = function (bool) fire_status = bool end,
    getFireStatus = function () return fire_status end,
    getWaitTime = function () return bullet_wait end,
    
    draw = function ()
      if fire_status == true then
        love.graphics.polygon("fill", sx, sy, sx+3.5, sy, sx, sy-10.5)
      end
    end
  }
end


--    Keypressed
function love.keypressed(key)
  if key == 'a' then
    
    bullet.setFireStatus(true)
    bullet.setSX(player.getX()+35/2)
    bullet.setSY(player.getY())
    
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


--      LOAD
function love.load()
  player =  newplayer()
  bullets = {}
  bullet = newbullet(player)
  listabls = {}
  for i = 1, 5 do
    listabls[i] = newblip(i/3, 0)
  end
end


--      DRAW
function love.draw()
  player.draw()
  for i = 1,#listabls do
    listabls[i].draw()
  end
  bullet.draw()
end


--      LOAD
function love.update(dt)
  nowTime = love.timer.getTime()
  
  -- Update Player
  player.update(dt) 
  
  -- Update blips
  for i = 1,#listabls do
    if listabls[i].getInactiveTime() <= nowTime then
      listabls[i].update()
    end
  end
  
  -- Update Bullet
  if bullet.getWaitTime() <= nowTime then
    bullet.update()
  end
  print("Sx: ", bullet.getSX(), "| Sy: ", bullet.getSY(), bullet.getFireStatus())
end
  

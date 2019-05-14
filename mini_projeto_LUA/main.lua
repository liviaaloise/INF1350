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
  local sx = player.getX()
  local sy = player.getY() - 1.5
  local fire_status = false
  local bullet_wait = 0
  local width, height = love.graphics.getDimensions( )
  
  local wait = function (seg)
    fire_status = false
    bullet_wait = love.timer.getTime() + seg
    coroutine.yield()
  end
  
  local function up()
--    while fire_status == true do
      print("\n\tDENTRO DO WHILE\n")
    if fire_status then  
      sy = sy - 15.0 
      if sy < 0 then 
        -- caso tiro passe da tela
        fire_status = false
      end
      -- coroutine.yield()
--      wait(1.0)
    end
  end
  return {
--    update = coroutine.wrap(up),
    update = up,
    getSX = function () return sx end,
    getSY = function () return sy end,
    setSX = function (x) sx = x end,
    setFireStatus = function (bool) fire_status = bool end,
    getFireStatus = function () return fire_status end,
    getWaitTime = function () return bullet_wait end,
    
    draw = function ()
      if fire_status == true then
        love.graphics.polygon("fill", sx, sy, sx+3.5, sy, sx, sy-7.5)
      end
    end
  }
end


--                                                  Keypressed
function love.keypressed(key)
  if key == 'a' then
    
    bullet.setFireStatus(true)
    bullet.setSX(player.getX())
    
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
  bullet = newbullet(player)
  listabls = {}
  for i = 1, 5 do
    listabls[i] = newblip(i/3, 0)
  end
end

function love.draw()
  player.draw()
  for i = 1,#listabls do
    listabls[i].draw()
  end
  bullet.draw()
end

function love.update(dt)
  
  nowTime = love.timer.getTime()

  player.update(dt)
  for i = 1,#listabls do
    if listabls[i].getInactiveTime() <= nowTime then
      listabls[i].update()
    end
--    if listabls[i].getActivity() == true then
--      listabls[i].update()
--    end
--    print(i, listabls[i].getActivity(), listabls[i].getInactiveTime(), nowTime)
--    print(i, listabls[i].getInactiveTime(), nowTime)
--  print(player.getFireStatus())
  end
--  if bullet.getWaitTime() <= nowTime then
--    bullet.update()
--  end
  bullet.update()
  print("Sx: ", bullet.getSX(), "| Sy: ", bullet.getSY(), bullet.getFireStatus())
end
  

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
  local rect_height = 10
  local rect_width = 35
  local width, height = love.graphics.getDimensions( )
  local speed = 2.5
  
  return {
    try = function ()
      return x
    end,
    
    update = function (dt)
      -- todo
      if love.keyboard.isDown('up') then player.incY(-speed) end
      if love.keyboard.isDown('down') then player.incY(speed) end
      if love.keyboard.isDown('left') then player.incX(-speed) end
      if love.keyboard.isDown('right') then player.incX(speed) end
      
      if (x + rect_width) > width then
        x = 0 -- player switch sides from right to left
      elseif x < 0 then
        x = width - rect_width -- player switch sides from left to right
      end
      if y > (height - rect_height) then
        y = height - rect_height -- player can't go any lower
      end
    end,
    
    getX = function () return x end,
    getY = function () return y end,
    setX = function (nx) x = nx end,
    setY = function (ny) y = ny end,
    incX = function (nx) x = x + nx end,
    incY = function (ny) y = y + ny end,
    
    getRectHeight = function () return rect_height end,
    getRectWidth = function () return rect_width end,
    
    draw = function ()
--      love.graphics.polygon("fill", x, y, x+10, y, x, y-10)
      love.graphics.rectangle("fill", x, y, rect_width, rect_height)
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
    while sy > 0  do
      sy = sy - 3.0 -- *Para variar o "passo" da bullet
      wait(0.005) -- *Para variar o tempo de espera/velocidade da bullet
    end
  end
  
  local function b ()
    local c = coroutine.create(up)
    return function ()
      return coroutine.resume(c)
    end
  end
  
  return {
    update = b(),
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
    
    bullet = newbullet(player)
    bullet.setFireStatus(true)
    bullet.setSX(player.getX()+35/2)
    table.insert(bullets_list, bullet)

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
  bullets_list = {}
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
  for i = 1,#bullets_list do
    bullets_list[i].draw()
  end
end


--    LOVE UPDATE
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
  
  -- Update Bullets
  for i = #bullets_list,1,-1 do
    if bullets_list[i].getWaitTime() <= nowTime then
      status = bullets_list[i].update()
      print(status)
      if status == false then
--        table.insert(to_removes, i)
        table.remove(bullets_list, i)
      end
    end
    print(#bullets_list)
  end
--  print("Sx: ", bullets_list[i].getSX(), "| Sy: ", bullets_list[i].getSY(), bullets_list[i].getFireStatus())
--  end
end
  

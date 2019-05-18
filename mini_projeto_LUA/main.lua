--                                                                      -- Blip
local function newblip (vel, posx)
  local x, y = posx, 0
  local width, height = love.graphics.getDimensions( )
  local inactiveTime = 0
  local square_size = 10
  local fire_rate = math.random(0.05, 1) -- TODO: adjust time between shots

  local wait = function (seg)
    inactiveTime = love.timer.getTime() + seg
    coroutine.yield()
  end

  local function up()
    while true do
      x = x + 15 -- x agora nao eh mais incrementado por vel
      if x > width then
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
      love.graphics.rectangle("fill", x, y, square_size, square_size)
    end,
    getXM = function () return x + square_size/2 end, -- Mid X
    getYL = function () return y + square_size end, -- Lower Y
    getInactiveTime = function () return inactiveTime end
  }
end


--                                                                    -- Player
local function newplayer ()
  local x = 0
  local y = 200
  local rect_height = 10
  local rect_width = 35
  local width, height = love.graphics.getDimensions( )
  local speed = 2.5
  local fire_rate = 0.5 -- time between shots
  local last_shot = 0

  return {
    try = function () return x end, -- TODO Delete and remove from keypressed

    update = function (dt)
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
    getXM = function () return x + rect_width/2 end,
    getY = function () return y end,
    getYM = function () return y - rect_height/2 end,
    incX = function (nx) x = x + nx end,
    incY = function (ny) y = y + ny end,
    getLastShot = function () return last_shot end,
    shoot_bullet = function () last_shot = love.timer.getTime() + fire_rate end,
    getRectHeight = function () return rect_height end,
    getRectWidth = function () return rect_width end,

    -- TODO: Test functions
    getSpeed = function () return speed end,
    getFireRate = function () return fire_rate end,
    incFireRate = function (i) fire_rate = fire_rate + i end, -- TODO
    incSpeed = function (vel) speed = speed + vel end, -- TODO

    draw = function ()
      love.graphics.rectangle("fill", x, y, rect_width, rect_height)
    end
  }
end


--                                                                    -- Bullet
local function newbullet (player)
  local sx = player.getXM()
  local sy = player.getY()
  local speed = 0.0005
  local bullet_wait = 0
  local width, height = love.graphics.getDimensions( )

  local wait = function (seg)
    bullet_wait = love.timer.getTime() + seg
    coroutine.yield()
  end
  local function up()
    while sy > 0  do
      sy = sy - 4.0 -- *Para variar o "passo" da bullet
      wait(speed) -- *Para variar o tempo de espera/velocidade da bullet
    end
  end
  local function move ()
    local wrapping = coroutine.create(up)
    return function ()
      return coroutine.resume(wrapping)
    end
  end

  return {
    update = move(),
    getSX = function () return sx end,
    getSY = function () return sy end,
    setSX = function (x) sx = x end,
    setSY = function (y) sy = y end,
    getWaitTime = function () return bullet_wait end,

    draw = function ()
      love.graphics.polygon("fill", sx, sy, sx+3.5, sy, sx, sy-10.5)
    end
  }
end


--                                                                    -- Attack
local function newattack (blipXM, blipYL)
  local x = blipXM
  local y = blipYL
  local step = 4.0
  local speed = 0.025
  local status = true -- TODO: make use of 'status' becomes false if player its hit or if y >= height
  local attack_wait = 0
  local width, height = love.graphics.getDimensions( )

  local wait = function (seg)
    attack_wait = love.timer.getTime() + seg
    coroutine.yield()
  end
  local function down()
    while status  do
      y = y + step
      if y >= height then
        status = false
      end
      wait(speed)
    end
  end
  local function move ()
    local wrapping = coroutine.create(down)
    return function ()
      return coroutine.resume(wrapping)
    end
  end

  return {
    update = move(),
    getX = function () return x end,
    getY = function () return y end,
    setX = function (xi) x = xi end,
    setY = function (yi) y = yi end,
    getWaitTime = function () return attack_wait end,

    -- TODO: Implement collision
    -- collision = function () end,

    draw = function ()
      if status then
        love.graphics.polygon("line", x, y, x+3.5, y, x, y-10.5)
      end
    end
  }
end


--                                                                     -- Items
local function newItem (sel, existence)
  -- use SEL to make different types of items TODO
  local width, height = love.graphics.getDimensions()
  local radius = 7.5
  local x = love.math.random(radius, width - 2*radius)
  local y = love.math.random(radius, height + 2*radius)
  local clock = 0.25
  local inactiveTime = 0
  local mode = {"inc_fire_rate", "dec_fire_rate", "inc_speed", "dec_speed"}
  local blink_mode = {"fill","line"}
  local blink = 0
  local active = true
  local created = love.timer.getTime()

  local wait = function (seg)
    inactiveTime = love.timer.getTime() + seg
    coroutine.yield()
  end

  local function stay()
    while (created+existence) > love.timer.getTime() do
      -- make it blink
      blink = bit.band(1,blink+1) -- bitwise: 1 & blink+1
      wait(clock) -- blink frequency
    end
  end

  local function exists ()
    local wrapping = coroutine.create(stay)
    return function ()
      return coroutine.resume(wrapping)
    end
  end

  return {
    update = exists(),
    gotcha = function (posX, posY)
      if posX > x - radius and posX < x + radius then
        if posY > y - radius and posY < y + radius then
          player.incSpeed(0.2) -- TODO TEST
          -- TODO: Update function to change player status like health, speed, fire rate....
          active = false
          return true
        end
        return false
      end
    end,
    draw = function ()
      if active then
        love.graphics.arc(blink_mode[blink+1], x, y, radius, 0, math.pi*2)
      end
    end,
    getInactiveTime = function () return inactiveTime end
  }
end


--    Keypressed
function love.keypressed(key)
  if key == 'a' then
    local last_shot = player.getLastShot()
    if (last_shot == 0) or (last_shot <= love.timer.getTime()) then
      -- print("LAST SHOT", last_shot) todo remove print
      player.shoot_bullet()
      local bullet = newbullet(player)
      bullet.setSX(player.getXM())
      table.insert(bullets_list, bullet)

      local pos = player.try()
      for i in ipairs(listabls) do
        local hit = listabls[i].affected(pos)
        if hit then
          table.remove(listabls, i) -- esse blip "morre"
          return -- assumo que apenas um blip morre
        end
      end
    end
  end
end


--      LOAD
function love.load()
  item_respawn = love.timer.getTime() + love.math.random(6,10)
  attack_respawn = love.timer.getTime() + 2.0 -- TODO testing: enemy shooting
  player =  newplayer()
  bullets_list = {}
  enemy_fire = {}
  items_list = {}
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
  for i = 1,#items_list do
    items_list[i].draw()
  end
  for i = 1,#enemy_fire do
    enemy_fire[i].draw()
  end
end


--    LOVE UPDATE
function love.update(dt)
  local nowTime = love.timer.getTime()

  -- Update Player
  player.update(dt)

  -- Update Items
  -- TODO: Try another solution instead of using 'item_respawn' as a global variable, to reduce lag
  if item_respawn < nowTime then
    -- item_respawn = item_respawn + love.math.random(3,8) -- time to generate next item
    item_respawn = item_respawn + love.math.random(10,20) -- time to generate next item
    table.insert(items_list, newItem(0, love.math.random(5,10))) -- time item will exist
  end

  -- Update blips
  for i = 1,#listabls do
    if listabls[i].getInactiveTime() <= nowTime then
      listabls[i].update()
    end
    if attack_respawn <= nowTime then
      -- TODO: Try another solution instead of using 'attack_respawn' as a global variable, to reduce lag
      attack_respawn = attack_respawn + 2.0 -- time between shots
      table.insert(enemy_fire, newattack(listabls[i].getXM(), listabls[i].getYL()))
    end
  end

  -- Update Bullets
  for i = #bullets_list,1,-1 do
    if bullets_list[i].getWaitTime() <= nowTime then
      local status = bullets_list[i].update()
      if status == false then
        table.remove(bullets_list, i)
      end
    end
  end

  -- Update Items
  for i = #items_list,1,-1 do
    print("Player Speed:", player.getSpeed()) -- TODO Test print
    -- Check if player passed through item
    if items_list[i].gotcha(player.getXM(), player.getYM()) then
      table.remove(items_list, i)
    elseif items_list[i].getInactiveTime() <= nowTime then
      local status = items_list[i].update()
      if status == false then
        table.remove(items_list, i)
      end
    end
  end

  print("Number of enemies bullets:", #enemy_fire)
  for i = #enemy_fire,1,-1 do
    if enemy_fire[i].getWaitTime() <= nowTime then
      print("\n\t\t\tGONNA UPDATE ENEMY FIRE\n")
      local status = enemy_fire[i].update()
      if status == false then
        table.remove(enemy_fire, i)
      end
    end
  end
--  print("Sx: ", bullets_list[i].getSX(), "| Sy: ", bullets_list[i].getSY(), bullets_list[i].getFireStatus())
--  end
end

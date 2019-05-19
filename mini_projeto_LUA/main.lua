--                                                                      -- Blip
local function newBlip (vel, posx)
  local x, y = posx, 0
  local width, height = love.graphics.getDimensions( )
  local inactiveTime = 0
  local square_size = 15
  local health = 10

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
    affected = function (posX, posY)
      if posX >= x and posX <= x+square_size then
        if posY >= y and posY <=y + square_size then
--          "pegou" o blip
          return true
        end
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
local function newPlayer ()
  local ship_img_lst = {love.graphics.newImage("ship.png"),
                        love.graphics.newImage("l.png"),
                        love.graphics.newImage("r.png")}
  local shipImg = ship_img_lst[1]
  local x = 200
  local y = 200
  local rect_height = shipImg:getHeight()
  local rect_width = shipImg:getWidth()
  local width, height = love.graphics.getDimensions( )
  local speed = 2.5
  local fire_rate = 0.5 -- shoot step
  local last_shot = 0

  return {
    update = function (dt)
      -- Make ship look straight if it's not going to left or right
      shipImg = ship_img_lst[1]
      if love.keyboard.isDown('up') then player.incY(-speed) end
      if love.keyboard.isDown('down') then player.incY(speed) end
      if love.keyboard.isDown('left') then
        player.incX(-speed)
        shipImg = ship_img_lst[2]
      end
      if love.keyboard.isDown('right') then
        player.incX(speed)
        shipImg = ship_img_lst[3]
      end

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
    getYL = function () return y + rect_height end, -- Y Lower bound
    getXR = function () return x + rect_width end, -- most far right X
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
      love.graphics.rectangle("line", x, y, rect_width, rect_height) -- TODO remove
      love.graphics.draw(shipImg, x+(rect_width/2), y, 0, 1,1, rect_width/2, 0)
    end
  }
end


--                                                                    -- Bullet
local function newBullet (player)
  local sx = player.getXM()
  local sy = player.getY()
  local speed = 0.0005
  -- local step = player.getFireRate()
  local bullet_wait = 0
  local width, height = love.graphics.getDimensions( )
  local bulletImg = love.graphics.newImage("shot.png")
  local radius = bulletImg:getHeight()/2

  local wait = function (seg)
    bullet_wait = love.timer.getTime() + seg
    coroutine.yield()
  end
  local function up()
    while sy > 0  do
      sy = sy - 4.0 -- *Para variar o "passo" da bullet
      for j = 1,#listabls do
        if listabls[j].affected(sx, sy) then
          table.remove(listabls,j) -- TODO CHANGE HERE TO ALLOW/NOT ALLOW DAMADGE FOR TESTS
          break
        end
      end
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
      love.graphics.draw(bulletImg, sx, sy, 0, 1,1, radius, radius)
    end
  }
end


--                                                                    -- Attack
local function newAttack (blipXM, blipYL)
  local x = blipXM
  local y = blipYL
  local step = 4.0
  local speed = 0.025 -- Blips shot speed
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
        -- TODO: Also set status = false if shot hit player
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


--                                                          -- Enemy Fire List
local function newAttackList ()
  local lst = {}
  local shot_cooldown = 2.5 -- Time between blips shots!
  local attack_wait = 0

  local wait = function (seg)
    attack_wait = love.timer.getTime() + seg
    coroutine.yield()
  end
  local function start_attack()
    while #listabls >= 1 do
      for i=1,#listabls do
        local blpXM = listabls[i].getXM()
        local blpYL = listabls[i].getYL()
        table.insert(lst, newAttack(blpXM, blpYL))
      end
      wait(shot_cooldown)
    end
  end
  local function move ()
    local wrapping = coroutine.create(start_attack)
    return function ()
      return coroutine.resume(wrapping)
    end
  end

  return {
    update = move(),
    getWaitTime = function () return attack_wait end,
    getEnemyFireList = function () return lst end,
    removeEnemyFireList = function (i) table.remove(lst,i) end,
  }
end



--                                                                     -- Items
local function newItem (sel, existence)
  -- use SEL to make different types of items TODO
  local width, height = love.graphics.getDimensions()
  local radius = 7.5
  local x = love.math.random(radius, width - 2*radius)
  local y = love.math.random(radius, height + 2*radius)
  local clock = 0.25  -- TODO: Fix item speed back to 0.25
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

  local function gotcha (posX1, posY1, posX2, posY2)
    if posX1 < x and posX2 > x then
      if posY1 < y and posY2 > y then
        player.incSpeed(0.3)
        -- TODO: Update function to change player status like health, speed, fire rate....
        active = false
        return true
      end
      return false
    end
  end

  local function stay()
    -- while active == true do
    while (created+existence) > love.timer.getTime() do
      -- make it blink
      blink = bit.band(1,blink+1) -- bitwise: 1 & blink+1

      local posX1 = player.getX()
      local posY1 = player.getY()
      local posX2 = player.getXR()
      local posY2 = player.getYL()
      -- Check if player caught item
      if gotcha(posX1, posY1, posX2, posY2) then
        active = false
        break
      end
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
    draw = function ()
      if active then
        love.graphics.arc(blink_mode[blink+1], x, y, radius, 0, math.pi*2)
      end
    end,
    getInactiveTime = function () return inactiveTime end
  }
end

--                                                       -- Item Generator List
local function newItemGenerator ()
  local lst = {}
  -- local item_respawn = love.math.random(10,20) -- time between items creation
  local item_respawn = love.math.random(6,8)
  local await_time = love.timer.getTime() + item_respawn -- game starts without items

  local wait = function (seg)
    await_time = love.timer.getTime() + seg
    -- item_respawn = love.math.random(5,20)
    item_respawn = love.math.random(5,20)
    coroutine.yield()
  end
  local function generate_item()
    while true do
      local sel = 0 -- TODO: Make use o sel to randomize items
      local duration = love.math.random(3,12) -- time item will exists
      table.insert(lst,newItem(sel, duration))
      wait(item_respawn)
    end
  end
  local function startUpdate ()
    local wrapping = coroutine.create(generate_item)
    return function ()
      return coroutine.resume(wrapping)
    end
  end

  return {
    update = startUpdate(),
    getWaitTime = function () return await_time end,
    getItemsList = function () return lst end,
    removeItem = function (i) table.remove(lst,i) end,
  }
end


--    Keypressed
function love.keypressed(key)
  if key == 'a' then
    local last_shot = player.getLastShot()
    if (last_shot == 0) or (last_shot <= love.timer.getTime()) then
      player.shoot_bullet()
      local bullet = newBullet(player)
      bullet.setSX(player.getXM())
      table.insert(bullets_list, bullet)
    end
  end
end


--      LOAD
function love.load()
  love.window.setTitle("Lua Game")
  --  Load Images
  bg = {image=love.graphics.newImage("bg.png"), x1=0, y1=0, x2=0, y2=0, width=0}
  bg.width=bg.image:getWidth()

  item_generator = newItemGenerator()
  player =  newPlayer()
  bullets_list = {}
  listabls = {}
  for i = 1, 5 do
    listabls[i] = newBlip(i/3, 0)
  end
  enemy_fire = newAttackList()
end


--      DRAW
function love.draw()
  --  Draw Images
  love.graphics.draw(bg.image, bg.x1, bg.y1)
  love.graphics.draw(bg.image, bg.x2, bg.y2)

  player.draw()
  for i = 1,#listabls do
    listabls[i].draw()
  end
  for i = 1,#bullets_list do
    bullets_list[i].draw()
  end
  local attack_lst = enemy_fire.getEnemyFireList()
  for i=1,#attack_lst do
    attack_lst[i].draw()
  end
  local items_lst = item_generator.getItemsList()
  for i=1,#items_lst do
    items_lst[i].draw()
  end
end


--    LOVE UPDATE
function love.update(dt)
  local nowTime = love.timer.getTime()

  -- Update Player
  player.update(dt)

  -- Update Items
  if item_generator.getWaitTime() <= nowTime then
    -- time between items creation
    item_generator.update()
  end
  local items_lst = item_generator.getItemsList()
  for i = #items_lst,1,-1 do
    -- print("Player Speed:", player.getSpeed()) -- TODO Test print
    if items_lst[i].getInactiveTime() <= nowTime then
      local status = items_lst[i].update()
      if status == false then
        item_generator.removeItem(i)
      end
    end
  end
  -- print("items size list:",#items_lst)

  -- Update blips
  for i = 1,#listabls do
    if listabls[i].getInactiveTime() <= nowTime then
      listabls[i].update()
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

  -- Update Enemy's attack, using two coroutines! One for shot speed and other as timer
  if enemy_fire.getWaitTime() <= nowTime then
    -- Wait time between blips shots
    enemy_fire.update()
  end
  local attack_lst = enemy_fire.getEnemyFireList()
  -- Blips bullet speed
  for i=#attack_lst,1,-1 do
    if attack_lst[i].getWaitTime() <= nowTime then
      local status = attack_lst[i].update()
      if status == false then
        enemy_fire.removeEnemyFireList(i)
      end
    end
  end
end

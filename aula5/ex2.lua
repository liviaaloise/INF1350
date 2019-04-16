function retangulo (x,y,w,h)
  local originalx, originaly, rx, ry, rw, rh = x, y, x, y, w, h
  return {
    draw =
    function ()
      love.graphics.rectangle("line", rx, ry, rw, rh)
    end,
    keypressed =
    function (key)
      local mx, my = love.mouse.getPosition()
      
      
      
    end
  }
  end
  
function love.load()
   ret1 = retangulo (50, 200, 200, 150);
end
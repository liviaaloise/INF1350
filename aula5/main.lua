
function naimagem (mx, my, x, y) 
  return (mx>x) and (mx<x+w) and (my>y) and (my<y+h)
end

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
      if naimagem (mx,my,x,y) then
        if key == 'b' and naimagem (mx,my, x, y) then
          y = yinit
        end
        if key =='down' then
          y = y + 10
        end
        if key == 'right' then
          x = x + 10
        end
      end
  end
      
  }
  end
  
function love.load()
   ret1 = retangulo (50, 200, 200, 150);
   ret2 = retangulo (150,150, 50, 50);
end


function love.keypressed(key)
  ret1.keypressed(key);
  ret2.keypressed(key);
end

function love.draw()
  ret1.draw()
  ret2.draw();
end
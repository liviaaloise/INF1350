local TAM = 700
local status = 1
local quantos = 10
local dist = 0.5
local raio = 0.3

local function desenhacirculo(x,y,raio)
  love.graphics.setColor(0.6, 0.5, 0.3)
  love.graphics.circle("line", x, y, raio)   
end

local desenha


desenha = coroutine.wrap(function(quantos, dist, raio)
  rec(quantos, dist, raio)
end
)

rec = function (quantos, dist, raio)
    if raio > TAM/100000 then
      for i = 1, quantos do
        love.graphics.push()
        love.graphics.rotate(-i*(2*math.pi)/quantos)
        love.graphics.setLineWidth(TAM/100000)
        desenhacirculo (0, dist, raio)
        love.graphics.pop()
      end
    end
    love.timer.sleep(0.5)
      raio = (3/4)*raio
      quantos = (4/3)*quantos
      coroutine.yield()
      rec(quantos, dist, raio)
      -- mudar: atualizar quantos e raio e chamar recursivamente!
  end

function love.load ()
  love.window.setTitle("circulos")
  love.window.setMode(TAM,TAM)
  love.graphics.setBackgroundColor(1,1,1)
end

function love.update (dt)
  love.timer.sleep(0.5)
  raio = (3/4)*raio
  quantos = (4/3)*quantos
end

function love.draw ()
  -- sistema normalizado [0,1]
  love.graphics.push()
  love.graphics.translate(TAM/2,TAM/2)
  love.graphics.scale(TAM/2,-TAM/2)
  desenha (quantos, dist, raio)
  love.graphics.pop()
end


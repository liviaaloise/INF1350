led1 = 3
led2 = 6
local meusleds = {led1, led2}
--local json = require 'json'

-- local chave = "897798401:AAGPcPo2wb3c-mWQA29dmIgJjHcsM5q8Gik"
-- local id_da_conversa = "694058925"
local endereco_base = "https://api.telegram.org/bot897798401:AAGPcPo2wb3c-mWQA29dmIgJjHcsM5q8Gik/getUpdates"
-- local endereco_base = "http://dontpad.com/reativos_mcu_teste_1421229"


for _,ledi in ipairs (meusleds) do
  gpio.mode(ledi, gpio.OUTPUT)
end

for _,ledi in ipairs (meusleds) do
  gpio.write(ledi, gpio.LOW);
end

local estadopisca={}
estadopisca[false]="OFF"
estadopisca[true]="ON_"

local piscando = {}
for _,ledi in ipairs (meusleds) do piscando[ledi] = false end
local apagado = {}
for _,ledi in ipairs (meusleds) do apagado[ledi] = true end

lastlux = 0

local function piscapisca (t)
  for _,i in ipairs (meusleds) do
    if piscando[i] then
      if apagado[i] then
        gpio.write(i, gpio.HIGH);
      else
        gpio.write(i, gpio.LOW);
      end
      apagado[i] = not apagado[i]
    end
  end
end

local function mudapisca (qualled, st)
  return function ()
    piscando[qualled] = st
  end
end

function readlux()
--  lastlux = adc.read(0)*(3.3/10.24)
-- MAX = 1027      -> 100
-- MEDIUM = 598.5  -> 60
-- MIN = 170       -> 17
-- Se lastlux <= 60 OK (iluminar com lanterna)!
-- TODO: identificar piscadas
  lastlux = adc.read(0)/10
  if lastlux <= 60.0 then
    gpio.write(led1, gpio.HIGH);
  else
    gpio.write(led1, gpio.LOW);
  end


end


function getMessages()
  print("endereço base" , endereco_base)
  http.get(endereco_base, nil, function(code, data)
    if (code < 0) then
      print("HTTP request failed")
    else
      -- dicionario_da_resposta = json.encode(data)
      -- for i=1, #dicionario_da_resposta["result"] do
      --   print(dicionario_da_resposta["result"][i]["message"]["text"])
      -- end
      -- print(code, dicionario_da_resposta)
      print(code, data)
    end
  end)
end


local actions = {
  TELEGRAM = getMessages,
  LERLUZ = readlux,
  LIGA1 = mudapisca(led1, true),
  DESLIGA1 = mudapisca(led1, false),
  LIGA2 = mudapisca(led2, true),
  DESLIGA2 = mudapisca(led2, false),
}

srv = net.createServer(net.TCP)

function receiver(sck, request)
  print("recebeu: " .. request)

  -- analisa pedido para encontrar valores enviados
  local _, _, method, path, vars = string.find(request, "([A-Z]+) ([^?]+)%?([^ ]+) HTTP");
  -- se nÃ£o conseguiu casar, tenta sem variÃ¡veis
  if(method == nil)then
    _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
  end

  local _GET = {}

  if (vars ~= nil)then
    for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
      _GET[k] = v
    end
  end


  local action = actions[_GET.pin]
  if action then action() end

  local vals = {
    --TEMP = string.format("%2.1f",adc.read(0)*(3.3/10.24)),
    LUZ =  string.format("%2.1f", lastlux),
    CHV1 = gpio.LOW,
    CHV2 = gpio.LOW,
    STLED1 = estadopisca[piscando[led1]],
    STLED2 = estadopisca[piscando[led2]],
  }


local buf = [[
<html>
<body>
<h1><u>PUC Rio</u></h1>
<h2><i>ESP8266 Web Server</i></h2>
        <p> Telegram <a href="?pin=TELEGRAM"><button><b>REFRESH</b></button></a>
        <p>Iluminacao: $LUZ lx <a href="?pin=LERLUZ"><button><b>REFRESH</b></button></a>
        <p>PISCA LED 1: $STLED1  <a href="?pin=LIGA1"><button><b>ON</b></button></a>
                            <a href="?pin=DESLIGA1"><button><b>OFF</b></button></a></p>
        <p>PISCA LED 2: $STLED2  <a href="?pin=LIGA2"><button><b>ON</b></button></a>
                            <a href="?pin=DESLIGA2"><button><b>OFF</b></button></a></p>
</body>
</html>
]]


buf = string.gsub(buf, "$(%w+)", vals)
sck:send(buf,
         function()  -- callback: fecha o socket qdo acabar de enviar resposta
           print("respondeu")
           sck:close()
         end)
       end

if srv then
  srv:listen(80, function(conn)
      print("CONN")
      conn:on("receive", receiver)
    end)
end

addr, port = srv:getaddr()
print(addr, port)
print("servidor inicializado.")

local mytimer = tmr.create()
mytimer:register(1000, tmr.ALARM_AUTO, piscapisca)
mytimer:start()

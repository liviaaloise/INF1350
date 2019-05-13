local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)

gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);

gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)

local tempoaceso = 200000
local tolerancia = 300000
local seqrodada = {}
local tamseq = 5
local isFirst = true;
local jogada = 1

local function geraseq (semente)
  print ("veja a sequencia:")
  tmr.delay(2*tempoaceso)
  print ("(" .. tamseq .. " itens)")
  math.randomseed(semente)
  isFirst = false;
  for i = 1,tamseq do
    seqrodada[i] = math.floor(math.random(1.5,2.5))
    print(seqrodada[i])
    gpio.write(3*seqrodada[i], gpio.HIGH)
    tmr.delay(3*tempoaceso)
    gpio.write(3*seqrodada[i], gpio.LOW)
    tmr.delay(2*tempoaceso)
  end
  print ("agora (seria) sua vez:")
end

local function leds(led)
  gpio.write(led,gpio.HIGH)
  tmr.delay(3*tempoaceso)
  gpio.write(led, gpio.LOW)
  
  if chave == sw1 then
    gpio.trig(sw1, "down", cbchave1)
  else
    gpio.trig(sw2, "down", cbchave2)
  end
end
      

local function cbcchave(chave)
  print(chave," x ", seqrodada[jogada])
  print("\n")
  if seqrodada[jogada] == chave then
    leds(3*chave)
    if jogada == 5 then
      print ("Voce Venceu!!!")
      leds(led2)
    end
  else 
    print ("Voce Perdeu!!!")
    leds(led1)
  end
  jogada = jogada + 1
  gpio.trig(sw1, "down", cbchave1)
end

function cbchave1 (_,contador)
  -- corta tratamento de interrup��es
  -- (passa a ignorar chave)
  gpio.trig(sw1)
  -- chama fun��o que trata chave
  print(isFirst)
  if isFirst then
    geraseq (contador)
  else 
    cbcchave(sw1)
  end
  gpio.trig(sw1, "down", cbchave1)
  gpio.trig(sw2, "down", cbchave2)
end


function cbchave2 (_,contador)
  -- corta tratamento de interrup��es
  -- (passa a ignorar chave)
  gpio.trig(sw2)
  -- chama fun��o que trata chave
  cbcchave(sw2)
  
end    

gpio.trig(sw1, "down", cbchave1)





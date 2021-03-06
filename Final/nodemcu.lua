local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2

local m
local topico = "1510952"
local ledState1 = gpio.LOW
local ledState2 = gpio.LOW
local ledState = gpio.LOW

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
gpio.write(led1, gpio.LOW)
gpio.write(led2, gpio.LOW)
gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)

function startMqttClientConnection() 
  local clientID = "Livia"
  m = mqtt.Client(clientID, 180)
  
  local mosquitoIP = "test.mosquitto.org"
  local port = 1883
  m:connect(mosquitoIP, port, 0,
     -- callback em caso de sucesso
    function(client)
      print("connected") 
      m:on("message", 
            function(client, topic, data)
              print("Topic:",topic)
              if topic == "1510952" then
                print('data: ', data)
                 if data=='led1' then
                    gpio.write(led1,gpio.HIGH)
                  elseif data=="led2" then
                    gpio.write(led2,gpio.HIGH)
                  elseif data=="off1" then
                    gpio.write(led1,gpio.LOW)
                  elseif data=='off2' then
                    gpio.write(led2,gpio.LOW)
                  end
              end
            end
          )
                  
      -- fç chamada qdo inscrição ok:
      m:subscribe(topico, 0, 
                    function (client)
                        print("subscribe success")
                        
                        function pressedButton1()
                            print("Button 1 pressed") 
                            m:publish(topico, "but1", 0, 1)
                        end
                        
                        function pressedButton2()
                            print("Button 2 pressed")
                            m:publish(topico, "but2", 0, 1)
                        end
                        
                        gpio.trig(sw1, "down", pressedButton1)
                        gpio.trig(sw2, "down", pressedButton2)
                    end,
                    
                    function(client, reason)
                        print("subscription failed reason: "..reason)
                    end
                  )
    end,
    -- callback em caso de falha 
    function(client, reason) 
      print("failed reason: "..reason) 
    end
  )
end


wificonf = {  
  -- verificar ssid e senha  
  ssid = "LIVIA",  
  pwd = "LIVIAROOM",
  got_ip_cb = function (con)
                print ("meu IP: ", con.IP)
                startMqttClientConnection()
              end,
  save = false
  }

wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)

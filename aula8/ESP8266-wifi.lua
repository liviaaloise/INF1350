local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2

local m
local topico = "1421229"
local ledState1 = gpio.LOW
local ledState2 = gpio.LOW

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
gpio.write(led1, gpio.LOW)
gpio.write(led2, gpio.LOW)
gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)


function startMqttClientConnection()
  local clientID = "Marcelo"
  m = mqtt.Client(clientID, 180)

  local mosquitoIP = "85.119.83.194"
  local port = 1883
  m:connect(mosquitoIP, port, 0,
     -- callback em caso de sucesso
    function(client)
      print("connected")
      m:on("message",
            function(client, topic, data)
              print("Topic:",topic,"\n")
              if topic == "1421229" then
                if data == "but1" then
                  if ledState1 == gpio.HIGH then
                    ledState1 = gpio.LOW
                  elseif ledState1 == gpio.LOW then
                    ledState1 = gpio.HIGH
                  end
                  gpio.write(led1, ledState1)

                elseif data == "but2" then
                  if ledState2 == gpio.HIGH then
                    ledState2 = gpio.LOW
                  elseif ledState2 == gpio.LOW then
                    ledState2 = gpio.HIGH
                  end
                  gpio.write(led2, ledState2)

                end
              end
            end
          )

      -- fç chamada qdo inscrição ok:
      m:subscribe(topico, 0,
                    function (client)
                        print("subscribe success")

                        function pressedButton1()
                            print("Button 1 pressed - Turn RED on/off")
                            m:publish(topico, "but1", 0, 1)
                        end

                        function pressedButton2()
                            print("Button 2 pressed - Turn GREEN on/off")
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
  ssid = "AndroidAP",
  pwd = "odxt2823",
  got_ip_cb = function (con)
                print ("meu IP: ", con.IP)
                startMqttClientConnection()
              end,
  save = false
  }

wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)

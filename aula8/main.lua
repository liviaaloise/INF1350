

local mqtt = require("mqtt-library")

function mqttcb(topic, message)
   print("Received from topic: " .. topic .. " - message:" .. message)
   if message=="but1" then
     controle = not controle
  elseif message== 'but2'  then
    controle2 = not controle2
  end
end

function love.keypressed(key)
  if key == 'a' then
    mqtt_client:publish("1421229", "a")
  end
end

function love.load()
  controle = false
  controle2 = false
  mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcb)
  mqtt_client:connect("cliente love 1")
  mqtt_client:subscribe({"1421229"})
end

function love.draw()
   if controle then
     love.graphics.rectangle("line", 10, 10, 200, 150)
   end
   if controle2 then
     love.graphics.rectangle('fill',300,10,200,150)
  end
end

function love.update(dt)
  mqtt_client:handler()
end
  
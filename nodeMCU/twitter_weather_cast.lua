package.loaded.email_communication = nil
local email = require 'email_communication'

local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2

local key = "********************"
local wifi_ssid = "********************"
local wifi_pwd = "********************"
local ifttt_API_url = "********************"


 gpio.mode(led1, gpio.OUTPUT)
 gpio.mode(led2, gpio.OUTPUT)
 gpio.write(led1, gpio.LOW)
 gpio.write(led2, gpio.LOW)
gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)

function readlux()
  local lastlux = adc.read(0)/10
  if lastlux <= 60.0 then
    gpio.write(led1, gpio.HIGH);
  else
    gpio.write(led1, gpio.LOW);
  end
  return lastlux
end

function post_tweet (lastlux)
  local tweet_post_url = ifttt_API_url .. key .. "?value1=" .. tostring(lastlux)
  http.post(tweet_post_url, nil, function(code, data)
    if (code < 0) then
      print("HTTP request failed")
    else
      print(code, "Tweet Posted")
    end
  end)
end


function pressedButton1 (_, contador)
  local lastlux = readlux()
  print("But1 Pressed!\tlx = " .. lastlux)
  post_tweet (lastlux)
end

function pressedButton2 ()
  local lastlux = readlux()
  print("But2 Pressed!\tlx = " .. lastlux)
  email.send(lastlux)
end

-- Set nodeMCU as a wifi.STATION
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=wifi_ssid, pwd=wifi_pwd})

gpio.trig(sw1, "down", pressedButton1)
gpio.trig(sw2, "down", pressedButton2)

-- TODO use timers...
-- local lux_timer = tmr.create() -- 0.1 sec
-- lux_timer:register(100, tmr.ALARM_AUTO, readlux)
-- lux_timer:start()

-- local tweet_timer = tmr.create() -- 30 sec
-- lux_timer:register(30000, tmr.ALARM_AUTO, readlux)
-- lux_timer:start()

-- TODO: discover how to get date:time on mcu
-- time = os.date("*t")
-- print("\n\n\t" .. time.hour .. ":" .. time.min .. ":" .. time.sec .. "\n\n")

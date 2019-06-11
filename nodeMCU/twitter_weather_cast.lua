local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2

local key = "********************"
local wifi_ssid = "********************"
local wifi_pwd = "********************"
local ifttt_API_url = "********************"

-- gpio.mode(led1, gpio.OUTPUT)
-- gpio.mode(led2, gpio.OUTPUT)
-- gpio.write(led1, gpio.LOW)
-- gpio.write(led2, gpio.LOW)
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

-- -- TODO TCP communication not working to send http POST... using http.post method above
-- local json = require "json"
-- conn = nil
-- conn=net.createConnection(net.TCP, 0)
-- conn:on("receive", function(conn, payload) end)
-- conn:connect(80,"maker.ifttt.com")
-- t = {
--   value1 = 30
-- }
-- message = json.enconde(t)
-- conn:on("connection", function(conn, payload)
--   conn:send("POST /trigger/post_tweet/with/key/<API-KEY> HTTP/1.1\r\n"
--   .. "Host: maker.ifttt.com\r\n"
--   .. "Connection: close\r\n"
--   .. "Accept: */*\r\n"
--   .. "Content-Type: application/json\r\n"
--   .. "Content-Length: " .. string.len(message) .. "\r\n\r\n"
--   .. message)
-- end)
-- conn:close()
-- print('Posted Tweet')

function pressedButton1 (_, contador)
  local lastlux = readlux()
  print("But1 Pressed!\tlx = " .. lastlux)
  post_tweet (lastlux)
end

-- Set nodeMCU as a wifi.STATION
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=wifi_ssid, pwd=wifi_pwd})

gpio.trig(sw1, "down", pressedButton1)

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

local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2

local key = "*****************"
local weather_key = "*********"
local wifi_ssid = "***********"
local wifi_pwd = "************"
local ifttt_API_url = "*******"

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
gpio.write(led1, gpio.LOW)
gpio.write(led2, gpio.LOW)
gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)

icons = {
  ["01"] = 1, -- ensolarado
  ["02"] = 2, -- sol com algumas nuvens
  ["03"] = 3, -- parcialmente nublado
  ["04"] = 4, -- nublado sem chuva
}

function warn_user ()
  gpio.write(led1, gpio.HIGH); -- Turn on RED led
  gpio.write(led2, gpio.LOW); -- Turn off GREEN led
end

function create_message(weather, curr_time, env_brightness)
  local message = ""
  if (weather_status == icons["01"] and curr_time == "morning") then
      if (env_brightness >= 90)  then
        warn_user()
        message = "Open your window, it's too dark in here"
      end
      if (env_brightness <= 40)  then
        warn_user()
        message = "Turn your lights off and open your window, you don't need to waste energy at this time"
      end
  end

  if (weather_status == icons["04"] and curr_time == "midnight" and env_brightness <= 60)  then
    warn_user()
    print("It's too late, turn your lights off and go to sleep! Take care of your vision")
  end
  return message
end

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

function email_send(brightness)
    local email_key = "by8p5qlIYimy6XPxB1xU5J"
    local email_post_url = "https://maker.ifttt.com/trigger/trigger2/with/key/" .. email_key .. "?value1=" .. tostring(brightness)
    http.post(email_post_url, nil, function(code, data)
    if (code < 0) then
        print("HTTP request failed")
    else
        print(code, "Email Sent")
    end
  end)
end

function sendTelegram(brightness)
  local telegramKey = "by8p5qlIYimy6XPxB1xU5J"
  local telegram_post_url = "https://maker.ifttt.com/trigger/sendMessage/with/key/" .. telegramKey .. "?value1=" .. tostring(brightness)
  http.post(telegram_post_url, nil, function(code, data)
  if (code < 0) then
      print("HTTP request failed")
  else
      print(code, "Email Sent")
  end
end)
end

function pressedButton1 ()
  local lastlux = readlux()
  print("But1 Pressed! Posting tweet...\n\tlx = " .. lastlux)
  post_tweet (lastlux)
  sendTelegram (lastlux)
end

function pressedButton2 ()
  local lastlux = readlux()
  print("But2 Pressed! Sending Email...\n\tlx = " .. lastlux)
  email_send (lastlux)
end

-- Set nodeMCU as a wifi.STATION
--wifi.setmode(wifi.STATION)
--wifi.sta.config({ssid=wifi_ssid, pwd=wifi_pwd})

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

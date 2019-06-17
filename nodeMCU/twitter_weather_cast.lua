local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2

local wifi_ssid = "***********"
local wifi_pwd = "************"
local key = "*****************"
local email_key = "***********"
local weather_key = "*********"
local ifttt_API_url = "*******"

-- local ifttt_API_url = "https://maker.ifttt.com/trigger/post_tweet/with/key/"
-- local owm_base_url = "http://api.openweathermap.org/data/2.5/weather?"
-- local city_id = 3451190 -- or use city_name = "Rio de Janeiro" -> &q=city_name
-- local OWM_API_endpoint = owm_base_url .. string.format("id=%d&APPID=%s", city_id, weather_key)

gpio.mode(led1, gpio.OUTPUT)
gpio.write(led1, gpio.LOW)
gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)

icons = {
  ["01"] = 1, -- ensolarado
  ["02"] = 2, -- sol com algumas nuvens
  ["03"] = 3, -- parcialmente nublado
  ["04"] = 4, -- nublado sem chuva
}

function warn_user (status)
  if status == 1 then
    led_status = 1
    gpio.write(led1, gpio.HIGH); -- Turn on RED led
  elseif status == 0 and led_status == 1 then
    led_status = 0
    gpio.write(led1, gpio.LOW); -- Turn off RED led
  end
end

-- function create_message(weather, curr_time, env_brightness)
function create_message(env_brightness)
  local status = 0
  local message = ""
  local tm = rtctime.epoch2cal(rtctime.get())

  if (weather_status == icons["01"] and curr_time == "morning") then
    if (env_brightness <= 40)  then
      status = 1
      message = "Turn your lights off and open your window, you don't need to waste energy at this time"
    end
    if (env_brightness >= 90)  then
        status = 1
        message = "Open your window, it's too dark in here"
    end
  end

  if (weather_status == icons["04"] and curr_time == "midnight" and env_brightness <= 60)  then
    status = 1
    print("It's too late, turn your lights off and go to sleep! Take care of your vision")
  end

  -- TODO delete test
  if (tonumber(tm["hour"]) > 23 or tonumber(tm["hour"]) < 3) and env_brightness < 60 then
    status = 1
  end
-- TODO delete test
  warn_user(status)
  -- return message
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
  local email_post_url = "https://maker.ifttt.com/trigger/trigger2/with/key/" .. email_key .. "?value1=" .. tostring(brightness)
  http.post(email_post_url, nil, function(code, data)
    if (code < 0) then
        print("HTTP request failed")
    else
        print(code, "Email Sent")
    end
  end)
end

-- Converts Unix epoch time to readable time
function convert_time ()
  local tm = rtctime.epoch2cal(rtctime.get())
  print(string.format("%02d/%02d/%04d %02d:%02d:%02d",
                      tm["day"], tm["mon"], tm["year"],
                      tm["hour"], tm["min"], tm["sec"]))
end


function get_weather()
  http.get(OWM_API_endpoint, nil, function(code, data)
    if (code < 0) then
        print("HTTP request failed")
    else
        print(code, "\tData:\n", data)
        local resp = sjson.decode(data)
        rtctime.set(resp.dt + resp.timezone)
        rtc_timer = tmr.create() -- 30 sec
        rtc_timer:register(6000, tmr.ALARM_AUTO, convert_time)
        rtc_timer:start()
    end
  end)
end

function sendTelegram(brightness)
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
  -- post_tweet (lastlux) -- TODO ---> UNDO
  -- sendTelegram (lastlux) -- TODO ---> UNDO

  get_weather()
end

function pressedButton2 ()
  local lastlux = readlux()
  print("But2 Pressed! Sending Email...\n\tlx = " .. lastlux)
  -- email_send (lastlux) -- TODO ---> UNDO

  create_message()
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

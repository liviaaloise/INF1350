
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid="****", pwd="*****"})

local key = "<API KEY"
local brightness = 590
local tweet_post_url = "https://maker.ifttt.com/trigger/post_tweet/with/key/" .. key .. "?value1=" .. tostring(brightness)
http.post(tweet_post_url, nil, function(code, data)
  if (code < 0) then
    print("HTTP request failed")
  else
    print(code, "Tweet Posted")
  end
end)

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

#!/usr/bin/lua
-- load the http socket module
http = require("socket.http")
-- load the json module
json = require("json")

api_url = "http://api.openweathermap.org/data/2.5/weather?"

-- http://openweathermap.org/help/city_list.txt , http://openweathermap.org/find
cityid = "5128581"

-- metric or imperial
cf = "imperial"

-- get an open weather map api key: http://openweathermap.org/appid
apikey = "cd9ced6183bd4fca41410cffdc1c8aa4"

location =  "Rio de Janeiro,BR"

weatherCSQueryURL = "http://api.openweathermap.org/data/2.5/weather?q=" + location + "&appid=" + apikey;


-- measure is °C if metric and °F if imperial
measure = '°' .. (cf == 'metric' and 'C' or 'F')

-- Unicode weather symbols to use
icons = {
  ["01"] = "☀",
  ["02"] = "🌤",
  ["03"] = "🌥",
  ["04"] = "☁",
  ["09"] = "🌧",
  ["10"] = "🌦",
  ["11"] = "🌩",
  ["13"] = "🌨",
  ["50"] = "🌫",
}

currenttime = os.date("!%Y%m%d%H%M%S")

file_exists = function (name)
    f=io.open(name,"r")
    if f~=nil then
        io.close(f)
        return true
    else
        return false
    end
end

if file_exists("weather.json") then
    cache = io.open("weather.json","r+")
    data = json.decode(cache:read())
    timepassed = os.difftime(currenttime, data.timestamp)
else
    cache = io.open("weather.json", "w")
    timepassed = 6000
end

makecache = function (s)
    s.timestamp = currenttime
    save = json.encode(s)
    cache:write(save)
end

if timepassed < 3600 then
    response = data
else
--    weather = http.request(("%sid=%s&units=%s&APPID=%s"):format(api_url, cityid, cf, apikey))
    weather = http.request(weatherCSQueryURL)
    if weather then
        response = json.decode(weather)
        makecache(response)
    else
        response = data
    end
end

math.round = function (n)
    return math.floor(n + 0.5)
end

temp = response.main.temp
conditions = response.weather[1].main
icon = response.weather[1].icon:sub(1, 2)

io.write(("%s %s%s %s\n"):format(icons[icon], math.round(temp), measure, conditions))

cache:close()


----TODO
---- url = "api.openweathermap.org/data/2.5/weather?q=London,uk&APPID=cd9ced6183bd4fca41410cffdc1c8aa4"
---- https://gist.github.com/meskarune/5729e8d6c8428e9c70a72bed475db4e1

---- Unicode weather symbols to use
--icons = {
--  ["01"] = "☀", -- ensolarado
--  ["02"] = "🌤", -- sol com algumas nuvens
--  ["03"] = "🌥", -- parcialmente nublado
--  ["04"] = "☁", -- nublado sem chuva
--  ["09"] = "🌧", -- nublado com chuva
--  ["10"] = "🌦", -- chuva com sol
--  ["11"] = "🌩", -- chuva com raios
--  ["13"] = "🌨", -- neve 
--  ["50"] = "🌫", -- neblina
--}

--print(icons["01"])



---- Unicode weather symbols to use
---- icons = {
----   ["01"] = "☀", -- ensolarado
----   ["02"] = "🌤", -- sol com algumas nuvens
----   ["03"] = "🌥", -- parcialmente nublado
----   ["04"] = "☁", -- nublado sem chuva
----   ["09"] = "🌧", -- nublado com chuva
----   ["10"] = "🌦", -- chuva com sol
----   ["11"] = "🌩", -- chuva com raios
----   ["13"] = "🌨", -- neve
----   ["50"] = "🌫", -- neblina
---- }

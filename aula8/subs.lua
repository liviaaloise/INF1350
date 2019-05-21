

wificonf = {  
  -- verificar ssid e senha  
  ssid = "Rafa",  
  pwd = "rafagato",  
  got_ip_cb = function (con)
                print ("meu IP: ", con.IP)
              end,
  save = false}

wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)
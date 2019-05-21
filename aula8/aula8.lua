--wificonf = {  
--  -- verificar ssid e senha  
--  ssid = "reativos",  
--  pwd = "reativos",  
--  got_ip_cb = function (con)
--                print ("meu IP: ", con.IP)
--              end,
--  save = false}
--
--wifi.setmode(wifi.STATION)
--wifi.sta.config(wificonf)

m = mqtt.Client("clientid", 120)
-- conecta com servidor mqtt na máquina 'ipbroker' e porta 1883:
m:connect("test.mosquitto.org", 1883, 0,
  -- callback em caso de sucesso  
  function(client) print("connected")
  m:subscribe("alos",0,  
       -- fç chamada qdo inscrição ok:
       function (client) 
         print("subscribe success") 
       end
)end, 
  -- callback em caso de falha 
  function(client, reason) 
    print("failed reason: "..reason) 
  end)


m:on("message", 
    function(client, topic, data)   
      print(topic .. ":" )   
      if data ~= nil then print(data) end
    end
)


